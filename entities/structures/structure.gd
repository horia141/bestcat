class_name Structure
extends StaticBody2D

enum StructureState {
	Operational,
	Destroyed
}

var state = StructureState.Operational

#region Constructor

func _ready() -> void:
	pass
	
func post_ready_prepare() -> void:
	pass
	
#endregion

#region Game logic

func on_hit_by_player_projectile() -> void:
	pass
	
#endregion
