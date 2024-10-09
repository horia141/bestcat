class_name Structure
extends StaticBody2D

enum StructureState {
	Operational,
	Destroyed
}

var state = StructureState.Operational

#region Game logic

func on_hit_by_player_projectile() -> void:
	pass
	
#endregion
