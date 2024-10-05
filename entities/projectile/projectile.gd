class_name Projectile
extends RigidBody2D

signal enemy_hit


func _on_body_entered(body: Node) -> void:
	if is_instance_of(body, TileMapLayer):
		pass
	elif body.is_in_group("Players"):
		return
	elif body.is_in_group("Enemies"):
		enemy_hit.emit(body)
	elif body.is_in_group("Projectiles"):
		return
	
	$AnimatedSprite2D.play("explosion")
	set_deferred("freeze", true)

func _on_animated_sprite_2d_animation_finished() -> void:
	# If we've triggered this animation, we exploded! Let's remove this!
	if $AnimatedSprite2D.animation == "explosion":
		queue_free()
