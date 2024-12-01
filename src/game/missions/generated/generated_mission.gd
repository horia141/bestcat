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
			
	algorithm.generate()
	_compute_terain_map()
	
	$PlayerStartPosition.position = Vector2(100, 100)
	$BossPosition.position = Vector2(300, 300)
	
	var dark_tower = DarkTowerScn.instantiate()
	dark_tower.position = Vector2(200, 200)
	# We don't call ppost_ready_prepare here as the game will do so
	add_child(dark_tower)
	
	init_completed.emit()

class GenerationAlgorithm:
	var desc: Application.MissionDesc
	var terrain: TileMapLayer
	var obstacles: TileMapLayer
	var decorations: TileMapLayer
	
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
		
	func generate() -> void:
		pass
		
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

	func generate() -> void:
		var size_to_gen = __map_size_to_cells(desc.size)
		var world_source_id = terrain.tile_set.get_source_id(0)
		
		for map_x in range(0, size_to_gen.x):
			for map_y in range(0, size_to_gen.y):
				# set the tile here with water
				terrain.set_cell(Vector2i(map_x, map_y), world_source_id, WATER_TILE_COORDS)
				
		var modified_cells = []
		var noise_image = noise_texture.get_image()
				
		for map_x in range(2, size_to_gen.x - 2):
			for map_y in range(2, size_to_gen.y - 2):
				# set the tile here with water
				var the_cell = Vector2i(map_x, map_y)
				var is_land_test = noise_image.get_pixel(map_x, map_y).r
				if is_land_test > LAND_THRESHOLD:
					terrain.set_cell(the_cell, world_source_id, GRASS_MAIN_TILE_COORDS)			
					modified_cells.append(the_cell)
				
		terrain.set_cells_terrain_connect(modified_cells, 0, 0)
					
		for modified_cell in modified_cells:
			var tile_test = randf_range(0, 1)
			if tile_test < 0.85:
				pass
			elif tile_test < 0.95:
				terrain.set_cell(modified_cell, world_source_id, GRASS_ALT0_TILE_COORDS)	
			elif tile_test < 0.98:
				terrain.set_cell(modified_cell, world_source_id, GRASS_ALT1_TILE_COORDS)
			else:
				terrain.set_cell(modified_cell, world_source_id, GRASS_ALT2_TILE_COORDS)
			
		terrain.update_internals()
		

#endregion
