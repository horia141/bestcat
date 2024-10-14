class_name Jelly
extends Mob

const EnemyProjectileScn = preload("res://entities/enemies/projectile/enemy-projectile.tscn")

static var SHOOT_PERIOD_SEC = DifficultyValue.new(1, 0.9, 0.8)

#region Game logic

func _shoot() -> void:
	if state != EnemyState.Active:
		return

	var enemy_projectile = EnemyProjectileScn.instantiate()
	enemy_projectile.post_ready_prepare(position, Vector2(-1, 0).rotated(randf_range(0, TAU)), difficulty)
	shoot.emit(enemy_projectile)
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC.get_for(difficulty) + randf_range(-0.25, 0.25)
	$ShootTimer.start()

#endregion
