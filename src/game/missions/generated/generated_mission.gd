class_name GeneratedMission
extends Mission

const DarkTowerScn = preload("res://entities/structures/dark-tower/dark-tower.tscn")

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
	
	var dark_tower = DarkTowerScn.instantiate()
	dark_tower.position = Vector2(200, 200)
	# We don't call ppost_ready_prepare here as the game will do so
	add_child(dark_tower)
	
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
		
		print(islands.size())
		_apply_to_terrain(modified_cells)
		
		var dark_tower_positions: Array[Vector2] = []
		var portals_positions: Array[Vector2] = []
		var result = GenerationAlgorithmResult.new()
		result.player_position = Vector2(100, 100)
		result.boss_position = Vector2(300, 300)
		result.dark_towers_positions = dark_tower_positions
		result.portals_positions = portals_positions
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
		
	func _apply_to_terrain(modified_cells: Dictionary) -> void:
		var world_source_id = terrain.tile_set.get_source_id(0)
		
		for map_x in range(0, size_to_gen.x):
			for map_y in range(0, size_to_gen.y):
				# set the tile here with water
				var pos = Vector2i(map_x, map_y)
				if pos not in modified_cells:
					terrain.set_cell(pos, world_source_id, WATER_TILE_COORDS)
				else:
					terrain.set_cell(pos, world_source_id, GRASS_MAIN_TILE_COORDS)
					
		var cells_to_apply: Array[Vector2i]
		for cel in modified_cells:
			cells_to_apply.append(cel)
					
		terrain.set_cells_terrain_connect(cells_to_apply, 0, 0)
		# terrain.update_internals()

		for pos in modified_cells:
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
					
	func _get_neighbors(pos: Vector2i) -> Array[Vector2i]:
		var neighbors: Array[Vector2i] = []

		if pos.x > 0:
			neighbors.append(pos + Vector2i(-1, 0))  # Left
		if pos.x < size_to_gen.x - 1:
			neighbors.append(pos + Vector2i(1, 0))   # Right
		if pos.y > 0:
			neighbors.append(pos + Vector2i(0, -1))  # Up
		if pos.y < size_to_gen.y - 1:
			neighbors.append(pos + Vector2i(0, 1))   # Down

		if pos.x > 0 and pos.y > 0:
			neighbors.append(pos + Vector2i(-1, -1))  # Top-left diagonal
		if pos.x < size_to_gen.x - 1 and pos.y > 0:
			neighbors.append(pos + Vector2i(1, -1))   # Top-right diagonal
		if pos.x > 0 and pos.y < size_to_gen.y - 1:
			neighbors.append(pos + Vector2i(-1, 1))   # Bottom-left diagonal
		if pos.x < size_to_gen.x - 1 and pos.y < size_to_gen.y - 1:
			neighbors.append(pos + Vector2i(1, 1))    # Bottom-right diagonal

		return neighbors

#endregion
