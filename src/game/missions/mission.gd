class_name Mission
extends Node2D

signal init_completed()
signal story_checkpoint_processed(checkpoint: Story.StoryCheckpoint)

enum GenerationMethod {
	HumanMade,
	Islands
}

enum MapSize {
	Small,
	Medium,
	Large,
	Custom
}

static func map_size_to_text(size: MapSize) -> String:
	match size:
		MapSize.Small:
			return "Small"
		MapSize.Medium:
			return "Medium"
		MapSize.Large:
			return "Large"
		MapSize.Custom:
			return "Custom"
	assert(1 != 0, "Unkown map size %s" % size)
	return "Unknown"

enum Challenge {
	Forgiving,
	Punishing,
	Deadly
}

static func challenge_to_text(challenge: Challenge) -> String:
	match challenge:
		Challenge.Forgiving:
			return "Forgiving"
		Challenge.Punishing:
			return "Punishing"
		Challenge.Deadly:
			return "Deadly"
	assert(1 != 0, "Unkown map size %s" % challenge)
	return "Unknown"

const WATER_TILE_COORDS = Vector2i(5, 6)
const GRASS_MAIN_TILE_COORDS = Vector2i(5, 0)

enum TerrainType {
	Water,
	Land,
	LandObstacle,
	LandDecoration
}

class TerrainCell:
	var type: TerrainType
	var is_blocked: bool

	func _init(type: TerrainType, is_blocked: bool) -> void:
		self.type = type
		self.is_blocked = is_blocked
		
class TerrainMap:
	var rows_cnt: int
	var cols_cnt: int
	var cells: Array[TerrainCell]
	var cells_size: Vector2i
	
	func _init(rows_cnt: int, cols_cnt: int, cells: Array[TerrainCell], cells_size: Vector2i) -> void:
		self.rows_cnt = rows_cnt
		self.cols_cnt = cols_cnt
		self.cells = cells
		self.cells_size = cells_size
		
	func get_cell(row: int, col: int) -> TerrainCell:
		return cells[row * cols_cnt + col]
		
	static func from_level(terrain: TileMapLayer, obstacles: TileMapLayer, decorations: TileMapLayer) -> TerrainMap:
		var rows_cnt = terrain.get_used_rect().size.y
		var cols_cnt = terrain.get_used_rect().size.x
		var cells: Array[TerrainCell] = []
		
		for row_idx in range(0, rows_cnt):
			for col_idx in range(0, cols_cnt):
				var coords = Vector2i(col_idx, row_idx)
				var terrain_cell = terrain.get_cell_tile_data(coords)
				var obstacle_cell = obstacles.get_cell_tile_data(coords)
				var decoration_cell = decorations.get_cell_tile_data(coords)
				
				var type = TerrainType.Land
				var is_blocked = false
				if terrain.get_cell_atlas_coords(coords) == WATER_TILE_COORDS:
					type = TerrainType.Water
					is_blocked = true
				elif obstacle_cell != null:
					type = TerrainType.LandObstacle
					is_blocked = true
				elif decoration_cell != null && decoration_cell.get_collision_polygons_count(0) > 0:
					type = TerrainType.LandDecoration
					is_blocked = true
					
				cells.push_back(TerrainCell.new(type, is_blocked))

		# Soome tiles are bigger than the standard size. We look at all such tiles
		# and block that particular region in the map too!
		for row_idx in range(0, rows_cnt):
			for col_idx in range(0, cols_cnt):
				var cell = cells[row_idx * cols_cnt + col_idx]
				var decoration_cell = decorations.get_cell_tile_data(Vector2i(col_idx, row_idx))
				
				if decoration_cell != null && decoration_cell.get_collision_polygons_count(0) > 0:
					var tile_atlas_coords = decorations.get_cell_atlas_coords(Vector2i(col_idx, row_idx))
					var tile_size = decorations.tile_set.get_source(0).get_tile_size_in_atlas(tile_atlas_coords)
					for tile_row_idx in range(-1 * floor(tile_size.y / 2.0), ceil(tile_size.y / 2.0)):
						for tile_col_idx in range(-1 * floor(tile_size.x / 2.0), ceil(tile_size.x / 2.0)):
							var final_idx = (row_idx + tile_row_idx) * cols_cnt + (col_idx + tile_col_idx)
							if cells[final_idx].type == TerrainType.Land:
								cells[final_idx].is_blocked = true
				
		return TerrainMap.new(rows_cnt, cols_cnt, cells, terrain.tile_set.tile_size)

var terrain_map: TerrainMap = null

var size_in_px: Vector2:
	get:
		var level_size_in_cells = $Level/Terrain.get_used_rect().size
		var tile_size_in_px = $Level/Terrain.tile_set.tile_size
		return level_size_in_cells * tile_size_in_px

#region Construction

func _ready() -> void:
	$Story.story_checkpoint_processed.connect(_story_checkpoint_processed)
	
func in_game_menu_prepare() -> void:
	terrain_map = TerrainMap.from_level($Level/Terrain, $Level/Obstacles, $Level/Decorations)
	
func post_ready_prepare(mission_desc: Application.MissionDesc) -> void:
	pass
	
func _compute_terain_map() -> void:
	terrain_map = TerrainMap.from_level($Level/Terrain, $Level/Obstacles, $Level/Decorations)
	#for row_idx in range(0, terrain_map.rows_cnt):
		#for col_idx in range(0, terrain_map.cols_cnt):
			#var new_disp = TextureRect.new()
			#new_disp.texture = CanvasTexture.new()
			#if terrain_map.get_cell(row_idx, col_idx).type == TerrainType.Water:
				#new_disp.modulate = Color.BLUE
			#elif terrain_map.get_cell(row_idx, col_idx).is_blocked:
				#new_disp.modulate = Color.RED
			#else:
				#new_disp.modulate = Color.SEA_GREEN
			#new_disp.position.x = col_idx * terrain_map.cells_size.y
			#new_disp.position.y = row_idx * terrain_map.cells_size.x
			#new_disp.size.x = 8
			#new_disp.size.y = 8
			#new_disp.z_index = 10
			#add_child(new_disp)
	

#endregion

#region Game logic

func advance_to_story_checkpoint(checkpoint: Story.StoryCheckpoint) -> void:
	$Story.advance_to_story_checkpoint(checkpoint)
	
func _story_checkpoint_processed(checkpoint: Story.StoryCheckpoint) -> void:
	story_checkpoint_processed.emit(checkpoint)

#endregion
