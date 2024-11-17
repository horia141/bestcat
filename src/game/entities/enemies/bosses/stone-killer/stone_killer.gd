class_name StoneKiller
extends Boss

const BulletScn = preload("res://entities/enemies/projectile/bullet/bullet.tscn")

static var Desc:
	get:
		return Application.EnemyDesc.new(
			"Stone Killer",
			"""
				A giant from the olden times. Hard to beat, and with powerful shots!
			""",
			preload("res://entities/enemies/bosses/stone-killer/stone-killer.tscn"),
			DifficultyValue.new(5, 10, 15)
		)

static var SHOOT_PERIOD_SEC = DifficultyValue.new(3, 2, 1.5)

#region Construction

func _ready() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", true)
	state = EnemyState.Hidden

#endregion

#region Game logic

func activate() -> void:
	super.activate()
	state = EnemyState.Active
	$CollisionShape2D.set_deferred("disabled", false)
	set_deferred("freeze", false)
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC.get_for(difficulty) + randf_range(-0.25, 0.25)
	$ShootTimer.start()

func _shoot() -> void:
	if state != EnemyState.Active:
		return
		
	$Sprite.play("attack")

	__shoot_one_round()
	await $Sprite.animation_finished
	if state != EnemyState.Active:
		# Got destroyed in the meanwhile!
		return
	__shoot_one_round()
	
	$Sprite.play("idle")
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC.get_for(difficulty) + randf_range(-0.25, 0.25)
	$ShootTimer.start()
	
func __shoot_one_round() -> void:
	var enemy_projectile_left = BulletScn.instantiate()
	enemy_projectile_left.post_ready_prepare(position, scale, Vector2(-1, 0).rotated(randf_range(-0.5, 0.5)), difficulty)
	shoot.emit(enemy_projectile_left)
	
	var enemy_projectile_top = BulletScn.instantiate()
	enemy_projectile_top.post_ready_prepare(position, scale, Vector2(0, -1).rotated(randf_range(-0.5, 0.5)), difficulty)
	shoot.emit(enemy_projectile_top)
	
	var enemy_projectile_right = BulletScn.instantiate()
	enemy_projectile_right.post_ready_prepare(position, scale, Vector2(1, 0).rotated(randf_range(-0.5, 0.5)), difficulty)
	shoot.emit(enemy_projectile_right)
	
	var enemy_projectile_down = BulletScn.instantiate()
	enemy_projectile_down.post_ready_prepare(position, scale, Vector2(0, 1).rotated(randf_range(-0.5, 0.5)), difficulty)
	shoot.emit(enemy_projectile_down)
		
func destroy() -> void:
	super.destroy()
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", true)
	$ShootTimer.stop()
	$Sprite.play("death")
	await $Sprite.animation_finished
	scale.x = 2
	scale.y = 2
	$Sprite.play("explosion")
	await $Sprite.animation_finished
	destroyed.emit()

#endregion
