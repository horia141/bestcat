class_name Jelly
extends Enemy


func _on_shoot_timer() -> void:
	var enemy_projectile_scn = preload("res://entities/enemy-projectile/enemy-projectile.tscn")
	
	var enemy_projectile = enemy_projectile_scn.instantiate()
	enemy_projectile.post_ready_prepare(position, Vector2(-1, 0).rotated(randf_range(0, TAU)))
	shoot.emit(enemy_projectile)
