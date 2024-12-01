class_name GeneratedMission
extends Mission

const DarkTowerScn = preload("res://entities/structures/dark-tower/dark-tower.tscn")
const PortalScn = preload("res://entities/structures/portal/portal.tscn")

static var Desc:
	get:
		return Application.MissionDesc.new(
			"A Generated Map", 
			"Nobody knows what terrors await you in this mission!",
			Mission.GenerationMethod.Islands,
			Mission.MapSize.Custom,
			Mission.Challenge.Forgiving,
			[Application.MissionDifficulty.Novice, Application.MissionDifficulty.Apprentice, Application.MissionDifficulty.Expert],
			preload("res://missions/generated/generated-mission.tscn")
		)
		
#region Construction

func post_ready_prepare(mission_desc: Application.MissionDesc) -> void:
	super.post_ready_prepare(mission_desc)
	
	var size_to_gen = GenerationAlgorithm.__map_size_to_cells(mission_desc.size)
	var algorithm: IslandsGenerationAlgorithm = null
	match mission_desc.method:
		Mission.GenerationMethod.Islands:
			# Something about the interaction between regular objects and this
			# one means that the noise textur needs to be generated outside
			# the generator.
			var the_noise = FastNoiseLite.new()
			the_noise.noise_type = FastNoiseLite.NoiseType.TYPE_PERLIN
			the_noise.frequency = 0.03
			the_noise.seed = randi()
			var noise_texture = NoiseTexture2D.new()
			noise_texture.width = size_to_gen.x
			noise_texture.height = size_to_gen.y
			noise_texture.noise = the_noise
			await noise_texture.changed
			#var noise_node = TextureRect.new()
			#noise_node.position = Vector2(0, 0)
			#noise_node.texture = noise_texture
			#add_child(noise_node)
		
			algorithm = IslandsGenerationAlgorithm.new(mission_desc, $Level/Terrain, $Level/Obstacles, $Level/Decorations, noise_texture)
		_:
			assert(1 != 0, "Invalid generation algorithm %s" % mission_desc.method)
			
	var result = algorithm.generate()
	_compute_terain_map()
	
	$PlayerStartPosition.position = result.player_position
	$BossPosition.position = result.boss_position
	
	for dark_tower_position in result.dark_towers_positions:
		var dark_tower = DarkTowerScn.instantiate()
		dark_tower.position = dark_tower_position
		add_child(dark_tower)
	
	for portal_position in result.portals_positions:
		var portal = PortalScn.instantiate()
		portal.position = portal_position
		add_child(portal)
	
	init_completed.emit()
	
	
class GenerationAlgorithmResult extends RefCounted:
	var player_position: Vector2
	var boss_position: Vector2
	var dark_towers_positions: Array[Vector2]
	var portals_positions: Array[Vector2]

class GenerationAlgorithm extends RefCounted:
	var desc: Application.MissionDesc
	var terrain: TileMapLayer
	var obstacles: TileMapLayer
	var decorations: TileMapLayer
	var size_to_gen: Vector2i
	
	func _init(
		desc: Application.MissionDesc,
		terrain: TileMapLayer,
		obstacles: TileMapLayer,
		decorations: TileMapLayer,
	) -> void:
		self.desc = desc
		self.terrain = terrain
		self.obstacles = obstacles
		self.decorations = decorations
		self.size_to_gen = __map_size_to_cells(desc.size)
		
	func generate() -> GenerationAlgorithmResult:
		assert(1 != 0, "Shouldn't use abstract base classes")
		return null
		
	var dark_towers_cnt: int:
		get:
			match desc.size:
				Mission.MapSize.Small:
					match desc.challenge:
						Mission.Challenge.Forgiving:
							return 4
						Mission.Challenge.Punishing:
							return 6
						Mission.Challenge.Deadly:
							return 8
				Mission.MapSize.Medium:
					match desc.challenge:
						Mission.Challenge.Forgiving:
							return 8
						Mission.Challenge.Punishing:
							return 12
						Mission.Challenge.Deadly:
							return 16
				Mission.MapSize.Large:
					match desc.challenge:
						Mission.Challenge.Forgiving:
							return 16
						Mission.Challenge.Punishing:
							return 24
						Mission.Challenge.Deadly:
							return 32
			assert(1 != 0, "Unknown size %d and challenge %d" % [desc.size, desc.challenge])
			return 1
		
	static func __map_size_to_cells(size: MapSize) -> Vector2i:
		match size:
			MapSize.Small:
				return Vector2i(50, 38)
			MapSize.Medium:
				return Vector2i(100, 76)
			MapSize.Large:
				return Vector2i(200, 152)
			MapSize.Custom:
				return Vector2i(50, 38)
		assert(1 == 0, "Invalid map size " % size)
		return Vector2i(100, 100)
		

class IslandsGenerationAlgorithm extends GenerationAlgorithm:
	class Island:
		var idx: int
		var cells: Array[Vector2i]
		
		func _init(idx: int) -> void:
			self.idx = idx
			self.cells = []
	
	const LAND_THRESHOLD = 0.5
	const SMALL_ISLAND_CELL_THRESHOLD = 150
	
	var noise_texture: NoiseTexture2D
	
	func _init(
		desc: Application.MissionDesc,
		terrain: TileMapLayer,
		obstacles: TileMapLayer,
		decorations: TileMapLayer,
		noise_texture: NoiseTexture2D
	) -> void:
		super(desc, terrain, obstacles, decorations)
		self.noise_texture = noise_texture

	func generate() -> GenerationAlgorithmResult:
		var modified_cells = _create_baseline_water_and_land()
		var islands = _compute_islands(modified_cells)
		modified_cells = _dilate_islands(modified_cells)
		islands = _compute_islands(modified_cells)
		islands = _eliminate_small_islands(islands)
		
		_apply_to_terrain(islands)
		
		var dark_tower_positions: Array[Vector2] = []
		var portals_positions: Array[Vector2] = []
		var result = GenerationAlgorithmResult.new()
		result.player_position = _place_player(islands, modified_cells)
		result.boss_position = _place_player(islands, modified_cells)
		result.dark_towers_positions = _build_dark_towers_for_islands(islands, modified_cells)
		result.portals_positions = _build_portals_for_islands(islands, modified_cells)
		return result
		
	func _create_baseline_water_and_land() -> Dictionary:
		var modified_cells = {}
		var noise_image = noise_texture.get_image()
				
		for map_x in range(2, size_to_gen.x - 2):
			for map_y in range(2, size_to_gen.y - 2):
				# set the tile here with water
				var the_cell = Vector2i(map_x, map_y)
				var is_land_test = noise_image.get_pixel(map_x, map_y).r
				if is_land_test > LAND_THRESHOLD:
					modified_cells[the_cell] = true
		
		return modified_cells
		
	func _compute_islands(modified_cells: Dictionary) -> Array[Island]:
		var islands: Array[Island] = []
		var visited = {}
		
		for pos in modified_cells:
			if pos not in visited:
				islands.append(_flood_fill(pos, visited, islands.size(), modified_cells))

		return islands
		
	func _dilate_islands(modified_cells: Dictionary) -> Dictionary:
		var new_modified_cells: Dictionary = {}
		
		for pos in modified_cells:
			for neighbor in _get_neighbors_no_edge(pos):
				if neighbor not in modified_cells:
					new_modified_cells[neighbor] = true
			new_modified_cells[pos] = true
					
		return new_modified_cells
		
	func _eliminate_small_islands(islands: Array[Island]) -> Array[Island]:
		var new_islands: Array[Island] = []
		for island in islands:
			if island.cells.size() > SMALL_ISLAND_CELL_THRESHOLD:
				island.idx = new_islands.size()
				new_islands.append(island)
		return new_islands
		
	func _flood_fill(start: Vector2i, visited: Dictionary, next_idx: int, modified_cells: Dictionary) -> Island:
		var stack = [start]
		visited[start] = true
		
		var island = Island.new(next_idx)

		while stack.size() > 0:
			var current = stack.pop_back()
			island.cells.append(current)

			for neighbor in _get_neighbors(current):
				if neighbor not in visited and neighbor in modified_cells:
					visited[neighbor] = true
					stack.append(neighbor)
					
		return island
		
	func _place_player(islands: Array[Island], modified_cells: Dictionary) -> Vector2:
		var island = _chose_random_island(islands)
		while true:
			var random_pos = island.cells.pick_random()
			if _is_sufficiencly_bufferd(random_pos, modified_cells):
				return Vector2(random_pos * terrain.tile_set.tile_size)
		assert(1 != 0, "Should not happen")
		return Vector2.ZERO
		
	func _build_dark_towers_for_islands(islands: Array[Island], modified_cells: Dictionary) -> Array[Vector2]:
		var dark_tower_positions: Array[Vector2] = []
		
		var total_mass: int = 0
		for island in islands:
			total_mass += island.cells.size()
		
		for idx in range(0, dark_towers_cnt):
			var island = _chose_random_island(islands)
			while true:
				var random_pos = island.cells.pick_random()
				if _is_sufficiencly_bufferd(random_pos, modified_cells):
					dark_tower_positions.append(Vector2(random_pos * terrain.tile_set.tile_size))
					break
				
		return dark_tower_positions
		
	func _build_portals_for_islands(islands: Array[Island], modified_cells: Dictionary) -> Array[Vector2]:
		var portal_positions: Array[Vector2] = []
		
		if islands.size() < 2:
			return portal_positions
			
		for island in islands:
			while true:
				var random_pos = island.cells.pick_random()
				if _is_sufficiencly_bufferd(random_pos, modified_cells):
					portal_positions.append(Vector2(random_pos * terrain.tile_set.tile_size))
					break
			
		return portal_positions
		
	func _apply_to_terrain(islands: Array[Island]) -> void:
		var world_source_id = terrain.tile_set.get_source_id(0)
		
		for map_x in range(0, size_to_gen.x):
			for map_y in range(0, size_to_gen.y):
				# set the tile here with water
				var pos = Vector2i(map_x, map_y)
				terrain.set_cell(pos, world_source_id, WATER_TILE_COORDS)
				
		for island in islands:
			for pos in island.cells:
				terrain.set_cell(pos, world_source_id, GRASS_MAIN_TILE_COORDS)
					
			terrain.set_cells_terrain_connect(island.cells, 0, 0)

			for pos in island.cells:
				var tile_test = randf_range(0, 1)
				# This was turned into something else by the connect
				if terrain.get_cell_atlas_coords(pos) != GRASS_MAIN_TILE_COORDS and terrain.get_cell_atlas_coords(pos) != GRASS_ALTX_TILE_COORDS:
					continue
						
				if tile_test < 0.85:
					pass
				elif tile_test < 0.95:
					terrain.set_cell(pos, world_source_id, GRASS_ALT0_TILE_COORDS)	
				elif tile_test < 0.98:
					terrain.set_cell(pos, world_source_id, GRASS_ALT1_TILE_COORDS)
				else:
					terrain.set_cell(pos, world_source_id, GRASS_ALT2_TILE_COORDS)

		terrain.update_internals()
		
	static func _chose_random_island(islands: Array[Island]) -> Island:
		var total_mass: int = 0
		for island in islands:
			total_mass += island.cells.size()
		var choice = randi_range(0, total_mass)
		var curr_mass: int = 0
		for island in islands:
			curr_mass += island.cells.size()
			if choice < curr_mass:
				return island
		assert(1 != 0, "This setup should never happen")
		return null
		
	static func _is_sufficiencly_bufferd(pos: Vector2i, modified_cells: Dictionary) -> bool:
		for pos_x in range(pos.x - 2, pos.x + 2):
			for pos_y in range(pos.y - 2, pos.y + 2):
				if Vector2i(pos_x, pos_y) not in modified_cells:
					return false
					
		return true
				
	static func _get_neighbors(pos: Vector2i) -> Array[Vector2i]:
		return [
			pos + Vector2i(-1, 0),  # Left
			pos + Vector2i(1, 0),   # Right
			pos + Vector2i(0, -1),  # Up
			pos + Vector2i(0, 1),   # Down
			pos + Vector2i(-1, -1), # Top-left diagonal
			pos + Vector2i(1, -1),  # Top-right diagonal
			pos + Vector2i(-1, 1),  # Bottom-left diagonal
			pos + Vector2i(1, 1),   # Bottom-right diagonal
		]
					
	func _get_neighbors_no_edge(pos: Vector2i) -> Array[Vector2i]:
		var neighbors: Array[Vector2i] = []

		if pos.x > 2:
			neighbors.append(pos + Vector2i(-1, 0))  # Left
		if pos.x < size_to_gen.x - 3:
			neighbors.append(pos + Vector2i(1, 0))   # Right
		if pos.y > 2:
			neighbors.append(pos + Vector2i(0, -1))  # Up
		if pos.y < size_to_gen.y - 3:
			neighbors.append(pos + Vector2i(0, 1))   # Down

		if pos.x > 2 and pos.y > 2:
			neighbors.append(pos + Vector2i(-1, -1))  # Top-left diagonal
		if pos.x < size_to_gen.x - 3 and pos.y > 2:
			neighbors.append(pos + Vector2i(1, -1))   # Top-right diagonal
		if pos.x > 2 and pos.y < size_to_gen.y - 3:
			neighbors.append(pos + Vector2i(-1, 1))   # Bottom-left diagonal
		if pos.x < size_to_gen.x - 3 and pos.y < size_to_gen.y - 3:
			neighbors.append(pos + Vector2i(1, 1))    # Bottom-right diagonal

		return neighbors

#endregion
