class_name Enemy
extends CharacterBody2D

signal shoot (projectile: EnemyProjectile)

#region Construction

func _on_ready() -> void:
	$AnimatedSprite2D.animation_finished.connect(__on_animated_sprite_2d_animation_finished)
	
func post_ready_prepare() -> void:
	pass
	
#endregion

#region Game logic

func on_hit_by_projectile() -> void:
	$ShootTimer.stop()
	$AnimatedSprite2D.play("explosion")
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", true)
	
func __on_animated_sprite_2d_animation_finished() -> void:
	# If we've triggered this animation, we exploded! Let's remove this!
	if $AnimatedSprite2D.animation == "explosion":
		queue_free()
		
#endregion
