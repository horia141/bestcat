class_name EnemyProjectile
extends RigidBody2D

signal player_hit (player: Player)

const BUFFER = 32
const SPEED = 1000

func _on_body_entered(body: Node) -> void:
	if is_instance_of(body, TileMapLayer):
		pass
	elif body.is_in_group("Players"):
		player_hit.emit(body as Player)
	elif body.is_in_group("Enemies"):
		return
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
