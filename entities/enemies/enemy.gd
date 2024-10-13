class_name Enemy
extends CharacterBody2D

signal shoot (projectile: EnemyProjectile)
signal destroyed ()

enum EnemyState {
	Hidden,
	Active,
	Dead
}

var state = EnemyState.Active
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

#endregion
