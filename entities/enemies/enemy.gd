extends CharacterBody2D

func _on_ready() -> void:
	$AnimatedSprite2D.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	
func on_hit_by_projectile() -> void:
	$ShootTimer.stop()
	$AnimatedSprite2D.play("explosion")
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", true)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	# If we've triggered this animation, we exploded! Let's remove this!
	if $AnimatedSprite2D.animation == "explosion":
		queue_free()
