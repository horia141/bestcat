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
const SPEED_REGEN_INCREMENT = 1
const SPEED_REGEN_CUTOFF = 10
const PROJECTILES_CNT_REGEN_INCREMENT = 1
const PROJECTILES_CNT_REGEN_CUTOFF = 10

const PlayerProjectileScn = preload("res://entities/player-projectile/player-projectile.tscn")

@export var in_game_scale: float = 1

var desc: Application.PlayerDesc = null
var mode = Application.ConceptMode.InGame
var state = PlayerState.Active
var difficulty = Application.MissionDifficulty.Apprentice
var look_axis: LookAxis = LookAxis.Right
var look_right: bool = true
var life = 5
var speed = 5
var speed_regen_factor = 0.0
var projectiles_cnt = 5
var projectiles_cnt_regen_factor = 0.0

#region Construction

func _ready() -> void:
	$SpeedRegenTimer.timeout.connect(_regen_speed)
	$ProjectilesCntRegenTimer.timeout.connect(_regen_projectile)
	
func post_ready_prepare(player_desc: Application.PlayerDesc, mode: Application.ConceptMode, init_position: Vector2, difficulty: Application.MissionDifficulty) -> void:
	self.z_index = 100
	self.z_as_relative = true
	self.scale = Vector2(in_game_scale, in_game_scale)
	self.position = init_position
	self.desc = player_desc
	self.mode = mode
	self.state = PlayerState.Active
	self.difficulty = difficulty
	self.life = player_desc.max_life
	self.speed = player_desc.max_speed
	self.speed_regen_factor = 0
	self.projectiles_cnt = player_desc.max_projectiles_cnt
	self.projectiles_cnt_regen_factor = 0

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
		position, look_direction.rotated(randf_range(-0.1, 0.1)), difficulty)
	shoot.emit(player_projectile)
	projectiles_cnt -= 1
	state_change.emit(PlayerEffect.NONE)
	
func _regen_speed() -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return
		
	if speed == desc.max_speed:
		return
		
	speed_regen_factor += SPEED_REGEN_INCREMENT
	if speed_regen_factor > SPEED_REGEN_CUTOFF:
		speed = speed + 1
		speed_regen_factor = 0.0
		
	state_change.emit(PlayerEffect.NONE)
	
func _regen_projectile() -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return

	if projectiles_cnt == desc.max_projectiles_cnt:
		return

	projectiles_cnt_regen_factor += PROJECTILES_CNT_REGEN_INCREMENT
	if projectiles_cnt_regen_factor > PROJECTILES_CNT_REGEN_CUTOFF:
		projectiles_cnt = projectiles_cnt + 1
		projectiles_cnt_regen_factor = 0.0
	
	state_change.emit(PlayerEffect.NONE)

func on_hit_by_projectile(enemy_projectile: EnemyProjectile) -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return

	enemy_projectile.apply_effect_to_player(self)
	life = clamp(life, 0, desc.max_life)
	speed = clamp(speed, 1, desc.max_speed)
	projectiles_cnt = clamp(projectiles_cnt, 0, desc.max_projectiles_cnt)
	
	if life == 0:
		state = PlayerState.Dead
		projectiles_cnt = 0
		projectiles_cnt_regen_factor = 0.0
	
	state_change.emit(PlayerEffect.NONE)
	
	# Schedule these big operations at the end!
	if state == PlayerState.Dead:
		$AnimatedSprite2D.play("explosion")
		$CollisionShape2D.set_deferred("disabled", true)
		set_deferred("freeze", true)
		await $AnimatedSprite2D.animation_finished
		destroyed.emit()
	
func apply_treasure(treasure: Treasure) -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return
		
	var effect = treasure.apply_effect_to_player(self)
	life = clamp(life, 0, desc.max_life)
	speed = clamp(speed, 1, desc.max_speed)
	projectiles_cnt = clamp(projectiles_cnt, 0, desc.max_projectiles_cnt)

	state_change.emit(PlayerEffect.new(effect))
	
func _look_at(new_look_axis: LookAxis) -> void:
	if mode != Application.ConceptMode.InGame:
		return
	if state == PlayerState.Dead:
		return
		
	look_axis = new_look_axis
	match new_look_axis:
		LookAxis.Right:
			look_right = true
		LookAxis.Left:
			look_right = false
	$AnimatedSprite2D.flip_h = !look_right
	
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
