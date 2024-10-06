class_name Enemy
extends CharacterBody2D

signal shoot (projectile: EnemyProjectile)
signal destroyed ()

#region Construction

func _ready() -> void:
	pass

func post_ready_prepare() -> void:
	pass
	
#endregion

#region Game logic

func on_hit_by_projectile() -> void:
	$ShootTimer.stop()
	$AnimatedSprite2D.play("explosion")
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", true)
	destroyed.emit()
	await $AnimatedSprite2D.animation_finished
	queue_free()
		
#endregion
