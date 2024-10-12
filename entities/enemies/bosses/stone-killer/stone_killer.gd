class_name Golem
extends Boss

var life = 10

const EnemyProjectileScn = preload("res://entities/enemy-projectile/enemy-projectile.tscn")

const SHOOT_PERIOD_SEC = 1.5

#region Construction

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
	
	if life == 0:
		state = EnemyState.Dead
		$ShootTimer.stop()
		$AnimatedSprite2D.play("explosion")
		$CollisionShape2D.set_deferred("disabled", true)
		set_deferred("freeze", true)
		await $AnimatedSprite2D.animation_finished
		destroyed.emit()
		queue_free()

#endregion