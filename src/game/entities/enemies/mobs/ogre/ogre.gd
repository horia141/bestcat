class_name Ogre
extends Mob

const EnemyProjectileScn = preload("res://entities/enemies/projectile/enemy-projectile.tscn")

static var SHOOT_PERIOD_SEC = DifficultyValue.new(1.5, 1.25, 1.00)

#region Game logic

func _shoot() -> void:
	if state != EnemyState.Active:
		return

	var enemy_projectile_left = EnemyProjectileScn.instantiate()
	enemy_projectile_left.post_ready_prepare(position, scale, Vector2(-1, 0).rotated(randf_range(-0.2, 0.2)), difficulty)
	shoot.emit(enemy_projectile_left)
	
	var enemy_projectile_top = EnemyProjectileScn.instantiate()
	enemy_projectile_top.post_ready_prepare(position, scale, Vector2(0, -1).rotated(randf_range(-0.2, 0.2)), difficulty)
	shoot.emit(enemy_projectile_top)
	
	var enemy_projectile_right = EnemyProjectileScn.instantiate()
	enemy_projectile_right.post_ready_prepare(position, scale, Vector2(1, 0).rotated(randf_range(-0.2, 0.2)), difficulty)
	shoot.emit(enemy_projectile_right)
	
	var enemy_projectile_down = EnemyProjectileScn.instantiate()
	enemy_projectile_down.post_ready_prepare(position, scale, Vector2(0, 1).rotated(randf_range(-0.2, 0.2)), difficulty)
	shoot.emit(enemy_projectile_down)
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC.get_for(difficulty) + randf_range(-0.25, 0.25)
	$ShootTimer.start()

#endregion
