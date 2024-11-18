class_name Zorax
extends Boss

const BulletScn = preload("res://entities/enemies/projectile/bullet/bullet.tscn")
const TranquilizerScn = preload("res://entities/enemies/projectile/tranquilizer/tranqulizer.tscn")

static var Desc:
	get:
		return Application.EnemyDesc.new(
			"Zorax",
			"""
				Zorax is a sneaky one! A demon for the modern age.
				
				He'll slow you down and then cut you up!
			""",
			preload("res://entities/enemies/bosses/zorax/zorax.tscn"),
			DifficultyValue.new(5, 10, 15)
		)

static var SHOOT_PERIOD_SEC = DifficultyValue.new(1, 0.75, 0.5)

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

	__shoot_slow_round()
	await $Sprite.animation_finished
	if state != EnemyState.Active:
		# Got destroyed in the meanwhile!
		return
	__shoot_hurt_round()
	
	$Sprite.play("idle")
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC.get_for(difficulty) + randf_range(-0.25, 0.25)
	$ShootTimer.start()
	
func __shoot_slow_round() -> void:
	var enemy_projectile = TranquilizerScn.instantiate()
	enemy_projectile.post_ready_prepare(
		position, 
		scale, 
		position.direction_to(player.position).rotated(randf_range(-0.2, 0.2)), 
		difficulty)
	shoot.emit(enemy_projectile)
	
func __shoot_hurt_round() -> void:
	var enemy_projectile = BulletScn.instantiate()
	enemy_projectile.post_ready_prepare(
		position, 
		scale, 
		position.direction_to(player.position).rotated(randf_range(-0.2, 0.2)), 
		difficulty)
	shoot.emit(enemy_projectile)
		
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
