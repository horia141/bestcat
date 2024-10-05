class_name PlayerProjectile
extends RigidBody2D

signal enemy_hit (enemy: Enemy)

const BUFFER = 32
const SPEED = 1000


func _on_body_entered(body: Node) -> void:
	if is_instance_of(body, TileMapLayer):
		pass
	elif body.is_in_group("Players"):
		return
	elif body.is_in_group("Enemies"):
		enemy_hit.emit(body as Enemy)
	elif body.is_in_group("Projectiles"):
		return
	
	$AnimatedSprite2D.play("explosion")
	set_deferred("freeze", true)

func _on_animated_sprite_2d_animation_finished() -> void:
	# If we've triggered this animation, we exploded! Let's remove this!
	if $AnimatedSprite2D.animation == "explosion":
		queue_free()
		
func post_ready_prepare(init_position: Vector2, init_direction: Vector2) -> void:
	position = init_position + BUFFER * init_direction
	add_constant_central_force(SPEED * init_direction)
