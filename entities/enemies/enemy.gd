class_name Enemy
extends CharacterBody2D

signal shoot (projectile: EnemyProjectile)
signal destroyed ()

enum EnemyState {
	Active,
	Dead
}

var state = EnemyState.Active

#region Construction

func _ready() -> void:
	pass

func post_ready_prepare(init_position: Vector2) -> void:
	position = init_position
	
#endregion

#region Game logic

func on_hit_by_projectile() -> void:
	pass

#endregion
