class_name Player
extends CharacterBody2D

signal shoot (projectile: PlayerProjectile)
signal state_change (effect: PlayerEffect)
signal destroyed ()


enum PlayerState {
	Active,
	Dead
}

class PlayerEffect extends RefCounted:
	var message: String
	
	static var NONE = PlayerEffect.new("")
	
	func _init(message: String) -> void:
		self.message = message

enum LookAxis {
	Up,
	Right,
	Down,
	Left
}

const SPEED_MULTIPLIER = 50.0
const SPEED_REGEN_CUTOFF = 10

const DEFENCE_MODE_DURATION_SEC = 0.4

const WEAPON_POS_LOOK_RIGHT = Vector2(8, -1)
const WEAPON_POS_LOOK_LEFT = Vector2(-8, -1)

const SHIELD_POS_LOOK_RIGHT = Vector2(-4, 3)
const SHIELD_POS_LOOK_LEFT = Vector2(4, 3)

const PlayerProjectileScn = preload("res://entities/players/projectile/player-projectile.tscn")

@export var in_game_scale: float = 1

var in_mission: Application.PlayerInMission = null
var mode = Application.ConceptMode.InGame
var state = PlayerState.Active
var difficulty = Application.MissionDifficulty.Apprentice
var weapon: PlayerWeapon = null
var shield: PlayerShield = null
var look_axis: LookAxis = LookAxis.Right
var look_right: bool = true
var life = 5
var speed = 5
var speed_regen_factor = 0.0
var projectiles_cnt = 5
var projectiles_cnt_regen_factor = 0.0
var defends_cnt = 3
var defends_cnt_regen_factor = 0.0
var in_defense_mode = false
var defend_tween: Tween = null
var powerup_tween: Tween = null
var destroy_tween: Tween = null

#region Construction

func _ready() -> void:
	pass
	
func post_ready_prepare(in_mission: Application.PlayerInMission, mode: Application.ConceptMode, init_position: Vector2, difficulty: Application.MissionDifficulty) -> void:
	self.z_index = 100
	self.z_as_relative = true
	self.scale = Vector2(in_game_scale, in_game_scale)
	self.position = init_position
	self.in_mission = in_mission
	self.mode = mode
	self.state = PlayerState.Active
	self.difficulty = difficulty
	self.life = in_mission.player.max_life
	self.speed = in_mission.player.max_speed
	self.speed_regen_factor = 0
	self.projectiles_cnt = in_mission.weapon.max_projectiles_cnt
	self.projectiles_cnt_regen_factor = 0
	self.defends_cnt = in_mission.shield.max_defends_cnt
	self.defends_cnt_regen_factor = 0
	
	if mode == Application.ConceptMode.InGame:
		weapon = in_mission.weapon.scene.instantiate() as PlayerWeapon
		weapon.post_ready_prepare(mode)
		weapon.position = WEAPON_POS_LOOK_RIGHT
		weapon.scale = Vector2(0.2, 0.2)
		add_child(weapon)
		
		shield = in_mission.shield.scene.instantiate() as PlayerShield
		shield.post_ready_prepare(mode)
		shield.position = SHIELD_POS_LOOK_RIGHT
		shield.scale = Vector2(0.2, 0.2)
		add_child(shield)
		
	$DefenceSprite.modulate = Color.TRANSPARENT
	$SpeedRegenTimer.timeout.connect(_regen_speed)
	$ProjectilesCntRegenTimer.timeout.connect(_regen_projectile)
	$DefendsCntRegenTimer.timeout.connect(_regen_defends)

#endregion

#region Game logic

func _shoot_projectile() -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return

	if projectiles_cnt == 0:
		return
	var player_projectile = PlayerProjectileScn.instantiate()
	var look_direction = Vector2(1, 0)
	match look_axis:
		LookAxis.Up:
			look_direction = Vector2(0, -1)
		LookAxis.Right:
			look_direction = Vector2(1, 0)
		LookAxis.Down:
			look_direction = Vector2(0, 1)
		LookAxis.Left:
			look_direction = Vector2(-1, 0)
	player_projectile.post_ready_prepare(
		position, 
		look_direction.rotated(randf_range(-1 / in_mission.weapon.accuracy, 1 / in_mission.weapon.accuracy)), 
		in_mission.weapon.damage,
		in_mission.weapon.speed,
		in_mission.weapon.range)
	shoot.emit(player_projectile)
	projectiles_cnt -= 1
	state_change.emit(PlayerEffect.NONE)
	
func _defend() -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return

	if defends_cnt == 0:
		return
	if in_defense_mode:
		return
		
	defends_cnt -= 1
	in_defense_mode = true
	state_change.emit(PlayerEffect.NONE)
	
	defend_tween = create_tween()
	$DefenceSprite.modulate = Color.TRANSPARENT
	defend_tween.tween_property($DefenceSprite, "modulate", Color.WHITE, 0.2)
	
	await get_tree().create_timer(DEFENCE_MODE_DURATION_SEC).timeout
	
	defend_tween = create_tween()
	defend_tween.tween_property($DefenceSprite, "modulate", Color.TRANSPARENT, 0.1)
	await defend_tween.finished
	in_defense_mode = false
	
func _regen_speed() -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return
		
	if speed == in_mission.player.max_speed:
		return
		
	speed_regen_factor += 1
	if speed_regen_factor > SPEED_REGEN_CUTOFF:
		speed = speed + 1
		speed_regen_factor = 0.0
		
	state_change.emit(PlayerEffect.NONE)
	
func _regen_projectile() -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return

	if projectiles_cnt == in_mission.weapon.max_projectiles_cnt:
		return

	projectiles_cnt_regen_factor += 1
	if projectiles_cnt_regen_factor > in_mission.weapon.reload_duration:
		projectiles_cnt = projectiles_cnt + 1
		projectiles_cnt_regen_factor = 0.0
	
	state_change.emit(PlayerEffect.NONE)
	
func _regen_defends() -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return
		
	if defends_cnt == in_mission.shield.max_defends_cnt:
		return
		
	defends_cnt_regen_factor += 1
	if defends_cnt_regen_factor > in_mission.shield.reload_duration:
		defends_cnt = defends_cnt + 1
		defends_cnt_regen_factor = 0.0
		
	state_change.emit(PlayerEffect.NONE)

func on_hit_by_projectile(enemy_projectile: EnemyProjectile) -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return
		
	if in_defense_mode:
		return
		
	destroy_tween = create_tween()
	destroy_tween.tween_property(self, "modulate", Color.RED, 0.2)
	destroy_tween.chain().tween_property(self, "modulate", Color.WHITE, 0.1)

	enemy_projectile.apply_effect_to_player(self)
	life = clamp(life, 0, in_mission.player.max_life)
	speed = clamp(speed, 1, in_mission.player.max_speed)
	projectiles_cnt = clamp(projectiles_cnt, 0, in_mission.weapon.max_projectiles_cnt)
	defends_cnt = clamp(defends_cnt, 0, in_mission.shield.max_defends_cnt)
	
	if life == 0:
		state = PlayerState.Dead
		projectiles_cnt = 0
		projectiles_cnt_regen_factor = 0.0
		defends_cnt = 0
		defends_cnt_regen_factor = 0.0
	
	state_change.emit(PlayerEffect.NONE)
	
	# Schedule these big operations at the end!
	if state == PlayerState.Dead:
		destroy()
	
func apply_treasure(treasure: Treasure) -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return
	
	if powerup_tween == null or not powerup_tween.is_running():
		powerup_tween = create_tween()
		powerup_tween.tween_property(self, "modulate", Color.GOLD, 0.15)
		powerup_tween.chain().tween_property(self, "modulate", Color.WHITE, 0.15)
		var powerup_scale_tween = powerup_tween.parallel()
		var initial_scale = self.scale
		powerup_scale_tween.tween_property(self, "scale", initial_scale * 1.2, 0.15).set_trans(Tween.TRANS_QUART)
		powerup_scale_tween.chain().tween_property(self, "scale", initial_scale, 0.15).set_trans(Tween.TRANS_SINE)
		
	var effect = treasure.apply_effect_to_player(self)
	life = clamp(life, 0, in_mission.player.max_life)
	speed = clamp(speed, 1, in_mission.player.max_speed)
	projectiles_cnt = clamp(projectiles_cnt, 0, in_mission.weapon.max_projectiles_cnt)
	defends_cnt = clamp(defends_cnt, 0, in_mission.shield.max_defends_cnt)

	state_change.emit(PlayerEffect.new(effect))
	
func destroy() -> void:
	if defend_tween != null:
		defend_tween.kill()
	if powerup_tween != null:
		powerup_tween.kill()
	if destroy_tween != null:
		destroy_tween.kill()
	self.modulate = Color.WHITE
	$AnimatedSprite2D.play("explosion")
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", true)
	await $AnimatedSprite2D.animation_finished
	destroyed.emit()
	
func _look_at(new_look_axis: LookAxis) -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return
		
	look_axis = new_look_axis
	match new_look_axis:
		LookAxis.Right:
			look_right = true
			weapon.position = WEAPON_POS_LOOK_RIGHT
			shield.position = SHIELD_POS_LOOK_RIGHT
		LookAxis.Left:
			look_right = false
			weapon.position = WEAPON_POS_LOOK_LEFT
			shield.position = SHIELD_POS_LOOK_LEFT
	$AnimatedSprite2D.flip_h = !look_right
	weapon.flip_h = !look_right
	shield.flip_h = !look_right
	
func _move_with_velocity(new_velocity: Vector2) -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return

	velocity = new_velocity * speed * SPEED_MULTIPLIER
	
var size_px: Vector2:
	get:
		return $CollisionShape2D.shape.get_rect().size

#endregion

#region Game events

func _input(event: InputEvent) -> void:
	if mode != Application.ConceptMode.InGame:
		return
	
	if event.is_action_pressed("Shoot"):
		_shoot_projectile()
	elif event.is_action_pressed("Defend"):
		_defend()

func _process(delta: float) -> void:
	if mode != Application.ConceptMode.InGame:
		return
	
	if Input.is_action_pressed("Move Up"):
		_look_at(LookAxis.Up)
	elif Input.is_action_pressed("Move Right"):
		_look_at(LookAxis.Right)
	elif Input.is_action_pressed("Move Down"):
		_look_at(LookAxis.Down)
	elif Input.is_action_pressed("Move Left"):
		_look_at(LookAxis.Left)

func _physics_process(delta: float) -> void:
	if mode != Application.ConceptMode.InGame:
		return
	
	_move_with_velocity(Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down"))
	move_and_slide()

#endregion
