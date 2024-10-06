class_name Enemy
extends CharacterBody2D

signal shoot (projectile: EnemyProjectile)
signal destroyed ()

#region Construction

func _ready() -> void:
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
	destroyed.emit()
	
func __on_animated_sprite_2d_animation_finished() -> void:
	# If we've triggered this animation, we exploded! Let's remove this!
	if $AnimatedSprite2D.animation == "explosion":
		queue_free()
		
#endregion
