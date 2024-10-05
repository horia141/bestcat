class_name PlayerProjectile
extends RigidBody2D

signal enemy_hit (enemy: Enemy)

const BUFFER = 32
const SPEED = 1000

#region Construction

func _on_ready() -> void:
	pass
	

func post_ready_prepare(init_position: Vector2, init_direction: Vector2) -> void:
	position = init_position + BUFFER * init_direction
	add_constant_central_force(SPEED * init_direction)

#endregion

#region Game logic

func _hit_player(player: Player) -> void:
	pass
	
func _hit_enemy(enemy: Enemy) -> void:
	enemy_hit.emit(enemy)
	_destroy()
	
func _hit_wall() -> void:
	_destroy()
	
func _destroy() -> void:
	$AnimatedSprite2D.play("explosion")
	set_deferred("freeze", true)

func __on_animated_sprite_2d_animation_finished() -> void:
	# If we've triggered this animation, we exploded! Let's remove this!
	if $AnimatedSprite2D.animation == "explosion":
		queue_free()

#endregion

#region Game events

func _on_body_entered(body: Node) -> void:
	if is_instance_of(body, TileMapLayer):
		_hit_wall()
	elif body.is_in_group("Players"):
		_hit_player(body as Player)
	elif body.is_in_group("Enemies"):
		_hit_enemy(body as Enemy)

#endregion
