class_name Enemy
extends CharacterBody2D

signal shoot (projectile: EnemyProjectile)
signal destroyed ()

enum EnemyState {
	Hidden,
	Inactive,
	Active,
	Dead
}

var state = EnemyState.Inactive
var difficulty = Application.MissionDifficulty.Apprentice

#region Construction

func _ready() -> void:
	pass

func post_ready_prepare(init_position: Vector2, difficulty: Application.MissionDifficulty) -> void:
	self.position = init_position
	self.difficulty = difficulty
	
	var immediate_activation = true
	for child in get_children():
		if child is EnemyActivationArea:
			child.player_entered.connect(_player_entered_activation_area)
			child.player_exited.connect(_player_exited_activation_area)
			immediate_activation = false
			return
			
	if immediate_activation:
		state = EnemyState.Active
	
#endregion

#region Game logic

func _player_entered_activation_area(player: Player) -> void:
	if state == EnemyState.Hidden or state == EnemyState.Dead:
		return
	state = EnemyState.Active
	$ShootTimer.wait_time = 0.1
	$ShootTimer.start()
	
func _player_exited_activation_area(player: Player) -> void:
	if state == EnemyState.Hidden or state == EnemyState.Dead:
		return
	state = EnemyState.Inactive

func on_hit_by_projectile() -> void:
	pass

#endregion
