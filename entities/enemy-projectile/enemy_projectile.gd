class_name EnemyProjectile
extends RigidBody2D

signal player_hit (player: Player)

const BUFFER = 32
const SPEED = 1000

#region Construction

func _ready() -> void:
	pass
	
func post_ready_prepare(init_position: Vector2, init_direction: Vector2) -> void:
	position = init_position + BUFFER * init_direction
	add_constant_central_force(SPEED * init_direction)

#endregion

#region Game logic

func _hit_player(player: Player) -> void:
	player_hit.emit(player)
	_destroy()
	
func _hit_enemy(enemy: Enemy) -> void:
	pass
	
func _hit_wall() -> void:
	_destroy()
	
func _hit_structure(structure: Structure) -> void:
	_destroy()
	
func _destroy() -> void:
	$AnimatedSprite2D.play("explosion")
	set_deferred("freeze", true)
	await $AnimatedSprite2D.animation_finished
	queue_free()

#endregion

#region Game events

func _on_body_entered(body: Node) -> void:
	if is_instance_of(body, TileMapLayer):
		_hit_wall()
	elif body.is_in_group("Structures"):
		_hit_structure(body as Structure)
	elif body.is_in_group("Players"):
		_hit_player(body as Player)
	elif body.is_in_group("Enemies"):
		_hit_enemy(body as Enemy)

#endregion
