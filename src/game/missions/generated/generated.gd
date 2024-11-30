class_name Generated
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
			preload("res://missions/generated/generated.tscn")
		)
		
#region Construction

func post_ready_prepare(mission_desc: Application.MissionDesc) -> void:
	super.post_ready_prepare(mission_desc)
	
	var algorithm: IslandsGenerationAlgorithm = null
	match mission_desc.method:
		Mission.GenerationMethod.Islands:
			algorithm = IslandsGenerationAlgorithm.new(self, mission_desc, $Level/Terrain, $Level/Obstacles, $Level/Decorations)
		_:
			assert(1 != 0, "Invalid generation algorithm %s" % mission_desc.method)
			
	algorithm.generate()
	
	$PlayerStartPosition.position = Vector2(100, 100)
	$BossPosition.position = Vector2(300, 300)
	
	var dark_tower = DarkTowerScn.instantiate()
	dark_tower.position = Vector2(200, 200)
	# We don't call ppost_ready_prepare here as the game will do so
	add_child(dark_tower)

class GenerationAlgorithm:
	var mission: Generated
	var desc: Application.MissionDesc
	var terrain: TileMapLayer
	var obstacles: TileMapLayer
	var decorations: TileMapLayer
	
	func _init(
		mission: Generated,
		desc: Application.MissionDesc,
		terrain: TileMapLayer,
		obstacles: TileMapLayer,
		decorations: TileMapLayer,
	) -> void:
		self.mission = mission
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
	func generate() -> void:
		var size_to_gen = __map_size_to_cells(desc.size)
		var world_source_id = terrain.tile_set.get_source_id(0)
		
		var texture = NoiseTexture2D.new()
		texture.width = size_to_gen.x
		texture.height = size_to_gen.y
		texture.noise = FastNoiseLite.new()
		
		print("there")
		texture.changed.connect(func (): self._gen_after_noise())
		#print("here")
		#var image = texture.get_image()
		#var data = image.get_data()
			
		var map_node = TextureRect.new()
		map_node.position = Vector2(0, 0)
		map_node.texture = texture
		terrain.get_parent().get_parent().add_child(map_node)
		
		for map_x in range(0, size_to_gen.x):
			for map_y in range(0, size_to_gen.y):
				# set the tile here with water
				terrain.set_cell(Vector2i(map_x, map_y), world_source_id, WATER_TILE_COORDS)

		terrain.update_internals()			
		
	func _gen_after_noise() -> void:
		print("here")
		var size_to_gen = __map_size_to_cells(desc.size)
		var world_source_id = terrain.tile_set.get_source_id(0)
	
		var modified_cells = []
				
		for map_x in range(2, size_to_gen.x - 2):
			for map_y in range(2, size_to_gen.y - 2):
				# set the tile here with water
				var the_cell = Vector2i(map_x, map_y)
				terrain.set_cell(the_cell, world_source_id, GRASS_MAIN_TILE_COORDS)			
				modified_cells.append(the_cell)
				
		terrain.set_cells_terrain_connect(modified_cells, 0, 0)
				
		terrain.update_internals()
		
		mission._compute_terain_map()
		
		mission.init_completed.emit()

#endregion
