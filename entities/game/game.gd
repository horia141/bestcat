extends Node


func _ready() -> void:
	var level_size_in_cells = $Level/Terrain.get_used_rect().size
	var tile_size_in_px = $Level/Terrain.tile_set.tile_size
	var level_size_in_px = level_size_in_cells * tile_size_in_px
	$BestCat/Camera2D.limit_right = level_size_in_px.x
	$BestCat/Camera2D.limit_bottom = level_size_in_px.y


func _on_best_cat_shoot() -> void:
	var input_direction_clean = Vector2(1 if $BestCat.look_right else -1, 0)
	var input_direction_jitter = randf_range(-0.1, 0.1)
	var input_direction = input_direction_clean.rotated(input_direction_jitter)
	var projectile_scene = preload("res://entities/projectile/projectile.tscn")
	var projectile = projectile_scene.instantiate()
	projectile.position = $BestCat.position + 32 * input_direction
	projectile.add_constant_central_force(1000 * input_direction)
	add_child(projectile)
