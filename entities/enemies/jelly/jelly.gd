extends "res://entities/enemies/enemy.gd"


func _on_shoot_timer() -> void:
	var enemy_projectile_scn = preload("res://entities/enemy-projectile/enemy-projectile.tscn")
	
	var enemy_projectile = enemy_projectile_scn.instantiate()
	var direction = Vector2(-1, 0).rotated(randf_range(0, TAU))
	enemy_projectile.position = position + 32 * direction
	enemy_projectile.add_constant_central_force(1000 * direction)
	
	shoot.emit(enemy_projectile)
