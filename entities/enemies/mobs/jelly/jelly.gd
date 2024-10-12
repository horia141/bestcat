class_name Jelly
extends Mob

const EnemyProjectileScn = preload("res://entities/enemy-projectile/enemy-projectile.tscn")

const SHOOT_PERIOD_SEC = 1

#region Game logic

func _shoot() -> void:
	if state != EnemyState.Active:
		return

	var enemy_projectile = EnemyProjectileScn.instantiate()
	enemy_projectile.post_ready_prepare(position, Vector2(-1, 0).rotated(randf_range(0, TAU)))
	shoot.emit(enemy_projectile)
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC + randf_range(-0.25, 0.25)
	$ShootTimer.start()

#endregion
