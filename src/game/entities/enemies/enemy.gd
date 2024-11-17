class_name Enemy
extends CharacterBody2D

signal shoot(projectile: EnemyProjectile)
signal state_change()
signal destroyed()

enum EnemyState {
	Hidden,
	Inactive,
	Active,
	Dead
}

var player: Game.PlayerProxy = null
var state = EnemyState.Inactive
var difficulty = Application.MissionDifficulty.Apprentice
var life = 1
var init_tween: Tween = null
var damage_tween: Tween = null

#region Construction

func _ready() -> void:
	pass

func post_ready_prepare(enemy_desc: Application.EnemyDesc, player: Game.PlayerProxy, init_position: Vector2, difficulty: Application.MissionDifficulty) -> void:
	self.player = player
	self.position = init_position
	self.difficulty = difficulty
	self.life = enemy_desc.max_life.get_for(difficulty)
	self.init_tween = create_tween()
	self.modulate = Color.TRANSPARENT
	$HealthBar.max_life = enemy_desc.max_life.get_for(difficulty)
	$HealthBar.life = life
	$Sprite.modulate = Color.WHITE
	$Sprite/WhiteMask.modulate = Color.WHITE
	init_tween.tween_property(self, "modulate", Color.WHITE, 0.5)
	init_tween.chain().tween_property($Sprite/WhiteMask, "modulate", Color.TRANSPARENT, 0.5)
	
#endregion

#region Game logic

func on_hit_by_projectile() -> void:
	if state == EnemyState.Hidden or state == EnemyState.Dead:
		return
	
	life = life - 1
	state_change.emit()
	
	$HealthBar.life = life
	
	if life == 0:
		destroy()
	
	var damage_tween = create_tween()
	damage_tween.tween_property(self, "modulate", Color.RED, 0.2)
	damage_tween.chain().tween_property(self, "modulate", Color.WHITE, 0.1)
	
func destroy() -> void:
	state = EnemyState.Dead
	if init_tween != null:
		init_tween.kill()
	if damage_tween != null:
		damage_tween.kill()
	self.modulate = Color.WHITE

#endregion
