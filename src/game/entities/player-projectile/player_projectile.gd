class_name PlayerProjectile
extends RigidBody2D

signal enemy_hit (enemy: Enemy)
signal structure_hit (structure: Structure)
signal otherwise_destroyed ()

const BUFFER = 32
static var SPEED = DifficultyValue.new(1000, 900, 800)

var difficulty = Application.MissionDifficulty.Apprentice

#region Construction

func _ready() -> void:
	pass
	

func post_ready_prepare(init_position: Vector2, init_direction: Vector2, difficulty: Application.MissionDifficulty) -> void:
	position = init_position + BUFFER * init_direction
	self.difficulty = difficulty
	add_constant_central_force(SPEED.get_for(difficulty) * init_direction)

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

#endregion
