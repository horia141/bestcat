extends "res://entities/enemies/enemy.gd"


func _on_shoot_timer() -> void:
	var enemy_projectile_scn = preload("res://entities/enemy-projectile/enemy-projectile.tscn")
	
	var enemy_projectile_left = enemy_projectile_scn.instantiate()
	var direction_left = Vector2(-1, 0).rotated(randf_range(-0.2, 0.2))
	enemy_projectile_left.position = position + 32 * direction_left
	enemy_projectile_left.add_constant_central_force(1000 * direction_left)
	shoot.emit(enemy_projectile_left)
	
	var enemy_projectile_top = enemy_projectile_scn.instantiate()
	var direction_top = Vector2(0, -1).rotated(randf_range(-0.2, 0.2))
	enemy_projectile_top.position = position + 32 * direction_top
	enemy_projectile_top.add_constant_central_force(1000 * direction_top)
	shoot.emit(enemy_projectile_top)
	
	var enemy_projectile_right = enemy_projectile_scn.instantiate()
	var direction_right = Vector2(1, 0).rotated(randf_range(-0.2, 0.2))
	enemy_projectile_right.position = position + 32 * direction_right
	enemy_projectile_right.add_constant_central_force(1000 * direction_right)
	shoot.emit(enemy_projectile_right)
	
	var enemy_projectile_down = enemy_projectile_scn.instantiate()
	var direction_down = Vector2(0, 1).rotated(randf_range(-0.2, 0.2))
	enemy_projectile_down.position = position + 32 * direction_down
	enemy_projectile_down.add_constant_central_force(1000 * direction_down)
	shoot.emit(enemy_projectile_down)
