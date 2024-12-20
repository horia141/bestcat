class_name Jelly
extends Mob

const BulletScn = preload("res://entities/enemies/projectile/bullet/bullet.tscn")

static var Desc:
	get:
		return Application.EnemyDesc.new(
			"Jelly",
			"""
				Jellies are a relatively weak enemy. They shoot in a random
				direction, and are easy to take out.
			""",
			preload("res://entities/enemies/mobs/jelly/jelly.tscn"),
			DifficultyValue.new(1, 1, 1)
		)

static var SHOOT_PERIOD_SEC = DifficultyValue.new(1, 0.9, 0.8)

#region Game logic

func _shoot() -> void:
	if state != EnemyState.Active:
		return

	var enemy_projectile = BulletScn.instantiate()
	enemy_projectile.post_ready_prepare(position, scale, Vector2(-1, 0).rotated(randf_range(0, TAU)), difficulty)
	shoot.emit(enemy_projectile)
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC.get_for(difficulty) + randf_range(-0.25, 0.25)
	$ShootTimer.start()

#endregion
