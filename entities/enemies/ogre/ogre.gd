class_name Ogre
extends Enemy

const EnemyProjectileScn = preload("res://entities/enemy-projectile/enemy-projectile.tscn")


func _on_shoot_timer() -> void:
	var enemy_projectile_left = EnemyProjectileScn.instantiate()
	enemy_projectile_left.post_ready_prepare(position, Vector2(-1, 0).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_left)
	
	var enemy_projectile_top = EnemyProjectileScn.instantiate()
	enemy_projectile_top.post_ready_prepare(position, Vector2(0, -1).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_top)
	
	var enemy_projectile_right = EnemyProjectileScn.instantiate()
	enemy_projectile_right.post_ready_prepare(position, Vector2(1, 0).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_right)
	
	var enemy_projectile_down = EnemyProjectileScn.instantiate()
	enemy_projectile_down.post_ready_prepare(position, Vector2(0, 1).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_down)
