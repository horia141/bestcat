class_name Snail
extends Mob

const TranquilizerScn = preload("res://entities/enemies/projectile/tranquilizer/tranqulizer.tscn")

static var Desc:
	get:
		return Application.EnemyDesc.new(
			"Evil Snail",
			"""
				Snails are slow and evil snails want everyone to be as slow
				as them. They're very good shots, and will slow you down.
			""",
			preload("res://entities/enemies/mobs/snail/snail.tscn"),
			DifficultyValue.new(1, 1, 1)
		)

static var SHOOT_PERIOD_SEC = DifficultyValue.new(1, 0.9, 0.8)

#region Game logic

func _shoot() -> void:
	if state != EnemyState.Active:
		return
		
	var enemy_projectile = TranquilizerScn.instantiate()
	enemy_projectile.post_ready_prepare(
		position, 
		scale, 
		position.direction_to(player.position).rotated(randf_range(-0.2, 0.2)), 
		difficulty)
	shoot.emit(enemy_projectile)
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC.get_for(difficulty) + randf_range(-0.25, 0.25)
	$ShootTimer.start()

#endregion
