class_name Ogre
extends Mob

const BulletScn = preload("res://entities/enemies/projectile/bullet/bullet.tscn")

static var Desc:
	get: 
		return Application.EnemyDesc.new(
			"Ogre",
			"""
				Ogres are tough to crack. They shoot many projectiles.
			""",
			preload("res://entities/enemies/mobs/ogre/ogre.tscn"),
			DifficultyValue.new(1, 1, 1)
		)

static var SHOOT_PERIOD_SEC = DifficultyValue.new(1.5, 1.25, 1.00)

#region Game logic

func _shoot() -> void:
	if state != EnemyState.Active:
		return

	var enemy_projectile_left = BulletScn.instantiate()
	enemy_projectile_left.post_ready_prepare(position, scale, Vector2(-1, 0).rotated(randf_range(-0.2, 0.2)), difficulty)
	shoot.emit(enemy_projectile_left)
	
	var enemy_projectile_top = BulletScn.instantiate()
	enemy_projectile_top.post_ready_prepare(position, scale, Vector2(0, -1).rotated(randf_range(-0.2, 0.2)), difficulty)
	shoot.emit(enemy_projectile_top)
	
	var enemy_projectile_right = BulletScn.instantiate()
	enemy_projectile_right.post_ready_prepare(position, scale, Vector2(1, 0).rotated(randf_range(-0.2, 0.2)), difficulty)
	shoot.emit(enemy_projectile_right)
	
	var enemy_projectile_down = BulletScn.instantiate()
	enemy_projectile_down.post_ready_prepare(position, scale, Vector2(0, 1).rotated(randf_range(-0.2, 0.2)), difficulty)
	shoot.emit(enemy_projectile_down)
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC.get_for(difficulty) + randf_range(-0.25, 0.25)
	$ShootTimer.start()
	
func is_bound_to_dark_tower() -> bool:
	return false

#endregion
