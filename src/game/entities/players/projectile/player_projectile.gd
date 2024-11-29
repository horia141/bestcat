class_name PlayerProjectile
extends RigidBody2D

signal enemy_hit (enemy: Enemy)
signal structure_hit (structure: Structure)
signal otherwise_destroyed ()

const BUFFER = 32

var init_position: Vector2 = Vector2.ZERO
var damage: float = 1
var speed: float = 100
var range: float = 200

#region Construction

func _ready() -> void:
	pass

func post_ready_prepare(init_position: Vector2, init_direction: Vector2, damage: float, speed: float, range: float) -> void:
	self.init_position = init_position
	position = init_position + BUFFER * init_direction
	self.damage = damage
	self.speed = speed
	self.range = range
	add_constant_central_force(speed * init_direction)

#endregion

#region Game logic
	
func _hit_wall() -> void:
	_destroy()
	
func _hit_structure(structure: Structure) -> void:
	structure_hit.emit(structure)
	_destroy()
	
func _hit_enemy(enemy: Enemy) -> void:
	enemy_hit.emit(enemy)
	_destroy()
	
func _destroy() -> void:
	$AnimatedSprite2D.play("explosion")
	set_deferred("freeze", true)
	await $AnimatedSprite2D.animation_finished
	otherwise_destroyed.emit()

#endregion

#region Game events

func _on_body_entered(body: Node) -> void:
	if is_instance_of(body, TileMapLayer):
		_hit_wall()
	elif body.is_in_group("Structures"):
		_hit_structure(body as Structure)
	elif body.is_in_group("Enemies"):
		_hit_enemy(body as Enemy)
		
func _process(delta: float) -> void:
	var distance_travelled = position.distance_to(init_position)
	if distance_travelled > range:
		_destroy()

#endregion
