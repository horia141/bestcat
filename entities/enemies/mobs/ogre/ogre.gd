class_name Ogre
extends Mob

const EnemyProjectileScn = preload("res://entities/enemy-projectile/enemy-projectile.tscn")

const SHOOT_PERIOD_SEC = 1.5

#region Game logic

func _shoot() -> void:
	if state != EnemyState.Active:
		return

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
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC + randf_range(-0.25, 0.25)
	$ShootTimer.start()

#endregion
