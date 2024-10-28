class_name Structure
extends StaticBody2D

enum StructureState {
	Operational,
	Destroyed
}

var player: Game.PlayerProxy = null
var state = StructureState.Operational
var difficulty = Application.MissionDifficulty.Apprentice

#region Constructors

func post_ready_prepare(player: Game.PlayerProxy, difficulty: Application.MissionDifficulty) -> void:
	self.player = player
	self.difficulty = difficulty

#endregion

#region Game logic

func on_hit_by_player_projectile() -> void:
	pass
	
#endregion
