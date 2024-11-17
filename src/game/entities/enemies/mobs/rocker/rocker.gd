class_name Rocker
extends Mob

const BulletScn = preload("res://entities/enemies/projectile/bullet/bullet.tscn")

static var Desc:
	get:
		return Application.EnemyDesc.new(
			"Rocker",
			"""
				Rockers don't do much in the way of damage, but they're hard to beat!
			""",
			preload("res://entities/enemies/mobs/rocker/rocker.tscn"),
			DifficultyValue.new(2, 2, 3)
		)

static var SHOOT_PERIOD_SEC = DifficultyValue.new(1.5, 1.2, 1)

#region Game logic

func _shoot() -> void:
	if state != EnemyState.Active:
		return

	var enemy_projectile = BulletScn.instantiate()
	enemy_projectile.post_ready_prepare(position, scale, Vector2(-1, 0).rotated(randf_range(0, TAU)), difficulty)
	shoot.emit(enemy_projectile)
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC.get_for(difficulty) + randf_range(-0.25, 0.25)
	$ShootTimer.start()
	
func is_bound_to_dark_tower() -> bool:
	return false

#endregion
