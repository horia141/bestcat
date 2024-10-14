class_name Mob
extends Enemy

#region Construction

#endregion

#region Game logic

func on_hit_by_projectile() -> void:
	super.on_hit_by_projectile()
	if state == EnemyState.Hidden or state == EnemyState.Dead:
		return
	state = EnemyState.Dead
	$ShootTimer.stop()
	$AnimatedSprite2D.play("explosion")
	$Collision.set_deferred("disabled", true)
	set_deferred("freeze", true)
	await $AnimatedSprite2D.animation_finished
	destroyed.emit()
	queue_free()

#endregion
