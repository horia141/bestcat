class_name Mob
extends Enemy

#region Construction

#endregion

#region Game logic

func on_hit_by_projectile() -> void:
	super.on_hit_by_projectile()
	if state == EnemyState.Dead:
		return
	state = EnemyState.Dead
	$ShootTimer.stop()
	$AnimatedSprite2D.play("explosion")
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", true)
	destroyed.emit()
	await $AnimatedSprite2D.animation_finished
	queue_free()

#endregion
