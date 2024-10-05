class_name Ogre
extends Enemy


func _on_shoot_timer() -> void:
	var enemy_projectile_scn = preload("res://entities/enemy-projectile/enemy-projectile.tscn")
	
	var enemy_projectile_left = enemy_projectile_scn.instantiate()
	enemy_projectile_left.post_ready_prepare(position, Vector2(-1, 0).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_left)
	
	var enemy_projectile_top = enemy_projectile_scn.instantiate()
	enemy_projectile_top.post_ready_prepare(position, Vector2(0, -1).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_top)
	
	var enemy_projectile_right = enemy_projectile_scn.instantiate()
	enemy_projectile_right.post_ready_prepare(position, Vector2(1, 0).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_right)
	
	var enemy_projectile_down = enemy_projectile_scn.instantiate()
	enemy_projectile_down.post_ready_prepare(position, Vector2(0, 1).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_down)
