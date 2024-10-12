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

#region Construction

func _ready() -> void:
	pass
	
func post_ready_prepare(init_position: Vector2) -> void:
	position = init_position

#endregion

#region Game logic

func on_hit_by_projectile() -> void:
	pass
	
func apply_treasure(treasure: Treasure) -> void:
	pass
	
#endregion
