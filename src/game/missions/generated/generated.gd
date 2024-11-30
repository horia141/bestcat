class_name Generated
extends Mission

const DarkTowerScn = preload("res://entities/structures/dark-tower/dark-tower.tscn")

static var Desc:
	get:
		return Application.MissionDesc.new(
			"A Generated Map", 
			"Nobody knows what terrors await you in this mission!",
			Mission.MapSize.Custom,
			Mission.Challenge.Forgiving,
			[Application.MissionDifficulty.Novice, Application.MissionDifficulty.Apprentice, Application.MissionDifficulty.Expert],
			preload("res://missions/generated/generated.tscn")
		)
		
#region Construction

func post_ready_prepare(mission_desc: Application.MissionDesc) -> void:
	var size_to_gen = __map_size_to_cells(mission_desc.size)
	
	var world_source_id = $Level/Terrain.tile_set.get_source_id(0)
	
	for map_x in range(0, size_to_gen.x):
		for map_y in range(0, size_to_gen.y):
			# set the tile here with water
			$Level/Terrain.set_cell(Vector2i(map_x, map_y), world_source_id, WATER_TILE_COORDS)
			
	
	var modified_cells = []
			
	for map_x in range(2, size_to_gen.x - 2):
		for map_y in range(2, size_to_gen.y - 2):
			# set the tile here with water
			var the_cell = Vector2i(map_x, map_y)
			$Level/Terrain.set_cell(the_cell, world_source_id, GRASS_MAIN_TILE_COORDS)			
			modified_cells.append(the_cell)
			
	$Level/Terrain.set_cells_terrain_connect(modified_cells, 0, 0)
			
	$Level/Terrain.update_internals()
	
	# Only call this when we have the map in place.		
	super.post_ready_prepare(mission_desc)
	
	$PlayerStartPosition.position = Vector2(100, 100)
	$BossPosition.position = Vector2(300, 300)
	
	var dark_tower = DarkTowerScn.instantiate()
	dark_tower.position = Vector2(200, 200)
	# We don't call ppost_ready_prepare here as the game will do so
	add_child(dark_tower)

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

#endregion
