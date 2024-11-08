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

var player: Game.PlayerProxy = null
var state = EnemyState.Inactive
var difficulty = Application.MissionDifficulty.Apprentice
var damage_tween: Tween = null

#region Construction

func _ready() -> void:
	pass

func post_ready_prepare(player: Game.PlayerProxy, init_position: Vector2, difficulty: Application.MissionDifficulty) -> void:
	self.player = player
	self.position = init_position
	self.difficulty = difficulty
	
#endregion

#region Game logic

func on_hit_by_projectile() -> void:
	var damage_tween = create_tween()
	damage_tween.tween_property(self, "modulate", Color.RED, 0.2)
	damage_tween.chain().tween_property(self, "modulate", Color.WHITE, 0.1)
	
func destroy() -> void:
	if damage_tween != null:
		damage_tween.kill()
	self.modulate = Color.WHITE

#endregion
