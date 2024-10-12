class_name Mission
extends Node2D

const WATER_TERRAIN_SET = 0
const WATER_TERRAIN = 4

var size_in_px = Vector2(100, 100)

#region Construction

func _ready() -> void:
	var level_size_in_cells = $Level/Terrain.get_used_rect().size
	var tile_size_in_px = $Level/Terrain.tile_set.tile_size
	size_in_px = level_size_in_cells * tile_size_in_px
	
func post_ready_prepare() -> void:
	pass

#endregion

#region Game logic

func get_appropriate_pos_for_enemy(enemy: Enemy) -> Vector2:
	# Look at the current position for an enemy and slighly adjust
	# it in order to not be placed in an inaccessible place.
	var local_pos_raw = to_local(enemy.global_position)
	var local_pos = Vector2(
		clampf(
			local_pos_raw.x,
			$Level/Terrain.tile_set.tile_size.x / 2, 
			size_in_px.x - $Level/Terrain.tile_set.tile_size.x / 2),
		clampf(
			local_pos_raw.y, 
			$Level/Terrain.tile_set.tile_size.y / 2, 
			size_in_px.y - $Level/Terrain.tile_set.tile_size.y / 2))
	
	var enemy_cell_pos = $Level/Terrain.local_to_map(local_pos)
	
	var ok_terrain_cell_pos = _find_closest_cell_not_on_water_nor_an_obstacle(enemy_cell_pos)
	var ok_terrain_cell = $Level/Terrain.get_cell_tile_data(ok_terrain_cell_pos)
	var ok_obstacle_cell = $Level/Obstacles.get_cell_tile_data(ok_terrain_cell_pos)
	
	if _is_water(ok_terrain_cell):
		assert(1 != 0, "Could not place cell on ok terrain!")
	if ok_obstacle_cell != null:
		assert(1 != 0, "Could not place cell on non obstacle")
		
	return to_global($Level/Terrain.map_to_local(ok_terrain_cell_pos))
	
func _find_closest_cell_not_on_water_nor_an_obstacle(initial_pos: Vector2i, max_radius: int = 10) -> Vector2i:
	# Convert world position to cell coordinates
	var initial_terrain_cell = $Level/Terrain.get_cell_tile_data(initial_pos)
	var initial_obstacle_cell = $Level/Obstacles.get_cell_tile_data(initial_pos)
	var initial_decoration_cell = $Level/Decorations.get_cell_tile_data(initial_pos)

	# If the initial cell is not water and not an obstacle, return it immediately
	if !_is_water(initial_terrain_cell) \
		and initial_obstacle_cell == null \
		and (initial_decoration_cell == null || (initial_decoration_cell != null && initial_decoration_cell.get_collision_polygons_count(0) > 0)):
		return initial_pos
	
	# Start searching nearby cells within a certain radius
	for radius in range(1, max_radius):
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				var new_pos = initial_pos + Vector2i(x, y)
				
				if new_pos == initial_pos:
					continue
				
				if !$Level/Terrain.get_used_rect().has_point(new_pos):
					continue
				
				var new_terrain_cell = $Level/Terrain.get_cell_tile_data(new_pos)
				var new_obstacle_cell = $Level/Obstacles.get_cell_tile_data(new_pos)
				var new_decorations_cell = $Level/Decorations.get_cell_tile_data(new_pos)
				
				if !_is_water(new_terrain_cell) \
					and new_obstacle_cell == null \
					and (new_decorations_cell == null || (new_decorations_cell != null && new_decorations_cell.get_collision_polygons_count(0) > 0)):
					return new_pos
	
	# If no non-water cell is found within max_radius, return the original position
	return initial_pos
	
static func _is_water(cell: TileData) -> bool:
	return cell.terrain_set == WATER_TERRAIN_SET and cell.terrain == WATER_TERRAIN
	
#endregion
