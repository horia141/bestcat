class_name EnemyProjectile
extends RigidBody2D

signal player_hit (player: Player)
signal otherwise_destroyed ()

const BUFFER = 32
static var SPEED = DifficultyValue.new(500, 750, 1000)

var difficulty = Application.MissionDifficulty.Apprentice

#region Construction

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func post_ready_prepare(init_position: Vector2, init_scale: Vector2, init_direction: Vector2, difficulty: Application.MissionDifficulty) -> void:
	position = init_position + BUFFER * init_scale * init_direction
	self.difficulty = difficulty
	add_constant_central_force(SPEED.get_for(difficulty) * init_direction)

#endregion

#region Game logic

func _hit_player(player: Player) -> void:
	# _hit_player works in tandem with apply_effect_to_player
	# The logic is projectile hits player and emits an event
	# Player handles being hit, and decides if the hit should occur
	# The player asks the projectile to compute its effect
	player_hit.emit(player)
	_destroy()

func apply_effect_to_player(player: Player) -> void:
	# See above!
	pass
	
func _hit_enemy(enemy: Enemy) -> void:
	_destroy()
	
func _hit_wall() -> void:
	_destroy()
	
func _hit_structure(structure: Structure) -> void:
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
	elif body.is_in_group("Players"):
		_hit_player(body as Player)
	elif body.is_in_group("Enemies"):
		_hit_enemy(body as Enemy)

#endregion
