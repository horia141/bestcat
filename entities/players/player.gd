class_name Player
extends CharacterBody2D

signal shoot (projectile: PlayerProjectile)
signal state_change ()
signal destroyed ()

enum PlayerState {
	Active,
	Dead
}

var state = PlayerState.Active
var difficulty = Application.MissionDifficulty.Apprentice

#region Construction

func _ready() -> void:
	pass
	
func post_ready_prepare(init_position: Vector2, difficulty: Application.MissionDifficulty) -> void:
	self.position = init_position
	self.difficulty = difficulty

#endregion

#region Game logic

func on_hit_by_projectile() -> void:
	pass
	
func apply_treasure(treasure: Treasure) -> void:
	pass
	
#endregion
