class_name Golem
extends Boss

const EnemyProjectileScn = preload("res://entities/enemy-projectile/enemy-projectile.tscn")

const SHOOT_PERIOD_SEC = 2
const MAX_LIFE = 10.0

var life = MAX_LIFE

#region Construction

func _ready() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", true)
	state = EnemyState.Hidden
	$HealthBar.max_life = MAX_LIFE
	$HealthBar.life = life

#endregion

#region Game logic

func activate() -> void:
	super.activate()
	state = EnemyState.Active
	$CollisionShape2D.set_deferred("disabled", false)
	set_deferred("freeze", false)
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC + randf_range(-0.25, 0.25)
	$ShootTimer.start()

func _shoot() -> void:
	if state != EnemyState.Active:
		return
		
	$AnimatedSprite2D.play("attack")

	__shoot_one_round()
	await $AnimatedSprite2D.animation_finished
	__shoot_one_round()
	
	$AnimatedSprite2D.play("idle")
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC + randf_range(-0.25, 0.25)
	$ShootTimer.start()
	
func __shoot_one_round() -> void:
	var enemy_projectile_left = EnemyProjectileScn.instantiate()
	enemy_projectile_left.post_ready_prepare(position, Vector2(-1, 0).rotated(randf_range(-0.5, 0.5)), difficulty)
	shoot.emit(enemy_projectile_left)
	
	var enemy_projectile_top = EnemyProjectileScn.instantiate()
	enemy_projectile_top.post_ready_prepare(position, Vector2(0, -1).rotated(randf_range(-0.5, 0.5)), difficulty)
	shoot.emit(enemy_projectile_top)
	
	var enemy_projectile_right = EnemyProjectileScn.instantiate()
	enemy_projectile_right.post_ready_prepare(position, Vector2(1, 0).rotated(randf_range(-0.5, 0.5)), difficulty)
	shoot.emit(enemy_projectile_right)
	
	var enemy_projectile_down = EnemyProjectileScn.instantiate()
	enemy_projectile_down.post_ready_prepare(position, Vector2(0, 1).rotated(randf_range(-0.5, 0.5)), difficulty)
	shoot.emit(enemy_projectile_down)

func on_hit_by_projectile() -> void:
	super.on_hit_by_projectile()
	if state != EnemyState.Active:
		return
	
	life = life - 1
	state_change.emit()
	
	$HealthBar.life = life
	
	if life == 0:
		state = EnemyState.Dead
		$CollisionShape2D.set_deferred("disabled", true)
		set_deferred("freeze", true)
		$ShootTimer.stop()
		$AnimatedSprite2D.play("death")
		await $AnimatedSprite2D.animation_finished
		scale.x = 2
		scale.y = 2
		$AnimatedSprite2D.play("explosion")
		await $AnimatedSprite2D.animation_finished
		destroyed.emit()
		queue_free()

#endregion
