class_name Player
extends CharacterBody2D

signal shoot (projectile: PlayerProjectile)
signal state_change ()

#region Game logic

func on_hit_by_projectile() -> void:
	pass
	
func apply_treasure(treasure: Treasure) -> void:
	pass
	
#endregion