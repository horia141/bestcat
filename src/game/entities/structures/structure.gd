class_name Structure
extends StaticBody2D

enum StructureState {
	Operational,
	Destroyed
}

var player: Game.PlayerProxy = null
var state = StructureState.Operational
var difficulty = Application.MissionDifficulty.Apprentice
var damage_tween: Tween = null

#region Constructors

func post_ready_prepare(all_mobs_desc: Array[Application.EnemyDesc], player: Game.PlayerProxy, difficulty: Application.MissionDifficulty, terrain_map: Mission.TerrainMap) -> void:
	self.player = player
	self.difficulty = difficulty

#endregion

#region Game logic

func on_hit_by_player_projectile(projectile: PlayerProjectile) -> void:
	damage_tween = create_tween()
	damage_tween.tween_property(self, "modulate", Color.RED, 0.2)
	damage_tween.chain().tween_property(self, "modulate", Color.WHITE, 0.1)
	
func destroy() -> void:
	if damage_tween != null:
		damage_tween.kill()
	self.modulate = Color.WHITE
	
#endregion
