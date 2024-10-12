class_name Golem
extends Boss

const EnemyProjectileScn = preload("res://entities/enemy-projectile/enemy-projectile.tscn")

const SHOOT_PERIOD_SEC = 1.5
const MAX_LIFE = 10.0

var life = MAX_LIFE

#region Construction

func _ready() -> void:
	$HealthBar.max_life = MAX_LIFE
	$HealthBar.life = life

#endregion

#region Game logic

func _shoot() -> void:
	if state == EnemyState.Dead:
		return
		
	$AnimatedSprite2D.play("attack")

	var enemy_projectile_left = EnemyProjectileScn.instantiate()
	enemy_projectile_left.post_ready_prepare(position, Vector2(-1, 0).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_left)
	
	var enemy_projectile_top = EnemyProjectileScn.instantiate()
	enemy_projectile_top.post_ready_prepare(position, Vector2(0, -1).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_top)
	
	var enemy_projectile_right = EnemyProjectileScn.instantiate()
	enemy_projectile_right.post_ready_prepare(position, Vector2(1, 0).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_right)
	
	var enemy_projectile_down = EnemyProjectileScn.instantiate()
	enemy_projectile_down.post_ready_prepare(position, Vector2(0, 1).rotated(randf_range(-0.2, 0.2)))
	shoot.emit(enemy_projectile_down)
	
	await $AnimatedSprite2D.animation_finished
	
	$ShootTimer.wait_time = SHOOT_PERIOD_SEC + randf_range(-0.25, 0.25)
	$ShootTimer.start()

func on_hit_by_projectile() -> void:
	super.on_hit_by_projectile()
	if state == EnemyState.Dead:
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
