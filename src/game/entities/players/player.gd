class_name Player
extends CharacterBody2D

signal shoot (projectile: PlayerProjectile)
signal state_change ()
signal destroyed ()


enum PlayerState {
	Active,
	Dead
}

enum LookAxis {
	Up,
	Right,
	Down,
	Left
}

static var MAX_LIFE = DifficultyValue.new(7, 5, 3)
static var MAX_SPEED = DifficultyValue.new(6, 5, 4)
const SPEED_MULTIPLIER = 50.0
const SPEED_REGEN_INCREMENT = 1
static var SPEED_REGEN_CUTOFF = DifficultyValue.new(5, 10, 15)
static var MAX_PROJECTILES_CNT = DifficultyValue.new(7, 5, 3)
const PROJECTILES_CNT_REGEN_INCREMENT = 1
static var PROJECTILES_CNT_REGEN_CUTOFF = DifficultyValue.new(5, 10, 15)

const PlayerProjectileScn = preload("res://entities/player-projectile/player-projectile.tscn")

@export var in_game_scale = 1

var state = PlayerState.Active
var difficulty = Application.MissionDifficulty.Apprentice
var look_axis: LookAxis = LookAxis.Right
var look_right: bool = true
var life = MAX_LIFE.get_for(difficulty)
var speed = MAX_SPEED.get_for(difficulty)
var speed_regen_factor = 0.0
var projectiles_cnt = MAX_PROJECTILES_CNT.get_for(difficulty)
var projectiles_cnt_regen_factor = 0.0

#region Construction

func _ready() -> void:
	$SpeedRegenTimer.timeout.connect(_regen_speed)
	$ProjectilesCntRegenTimer.timeout.connect(_regen_projectile)
	
	
func post_ready_prepare(init_position: Vector2, difficulty: Application.MissionDifficulty) -> void:
	self.z_index = 100
	self.z_as_relative = true
	self.scale = Vector2(in_game_scale, in_game_scale)
	self.position = init_position
	self.difficulty = difficulty
	self.life = MAX_LIFE.get_for(difficulty)
	self.speed = MAX_SPEED.get_for(difficulty)
	self.speed_regen_factor = 0
	self.projectiles_cnt = MAX_PROJECTILES_CNT.get_for(difficulty)
	self.projectiles_cnt_regen_factor = 0

#endregion

#region Game logic

func _shoot_projectile() -> void:
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
	state_change.emit()
	
func _regen_speed() -> void:
	if state == PlayerState.Dead:
		return
		
	if speed == MAX_SPEED.get_for(difficulty):
		return
		
	speed_regen_factor += SPEED_REGEN_INCREMENT
	if speed_regen_factor > SPEED_REGEN_CUTOFF.get_for(difficulty):
		speed = speed + 1
		speed_regen_factor = 0.0
		
	state_change.emit()
	
func _regen_projectile() -> void:
	if state == PlayerState.Dead:
		return

	if projectiles_cnt == MAX_PROJECTILES_CNT.get_for(difficulty):
		return

	projectiles_cnt_regen_factor += PROJECTILES_CNT_REGEN_INCREMENT
	if projectiles_cnt_regen_factor > PROJECTILES_CNT_REGEN_CUTOFF.get_for(difficulty):
		projectiles_cnt = projectiles_cnt + 1
		projectiles_cnt_regen_factor = 0.0
	
	state_change.emit()

func on_hit_by_projectile(enemy_projectile: EnemyProjectile) -> void:
	if state == PlayerState.Dead:
		return

	enemy_projectile.apply_effect_to_player(self)
	life = clamp(life, 0, MAX_LIFE.get_for(difficulty))
	speed = clamp(speed, 1, MAX_SPEED.get_for(difficulty))
	
	if life == 0:
		state = PlayerState.Dead
		projectiles_cnt = 0
		projectiles_cnt_regen_factor = 0.0
	
	state_change.emit()
	
	# Schedule these big operations at the end!
	if state == PlayerState.Dead:
		$AnimatedSprite2D.play("explosion")
		$CollisionShape2D.set_deferred("disabled", true)
		set_deferred("freeze", true)
		await $AnimatedSprite2D.animation_finished
		destroyed.emit()
	
func apply_treasure(treasure: Treasure) -> void:
	if state == PlayerState.Dead:
		return
	
	if treasure is LifePowerUp:
		life = min(life + 1, MAX_LIFE.get_for(difficulty))
	elif treasure is ProjectilePowerUp:
		projectiles_cnt = min(projectiles_cnt + 1, MAX_PROJECTILES_CNT.get_for(difficulty))
		projectiles_cnt_regen_factor = 0.0
	else:
		assert(0 == 1, "Invalid treasure: " + str(treasure))
		
	state_change.emit()
	
func _look_at(new_look_axis: LookAxis) -> void:
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
	if state == PlayerState.Dead:
		return

	velocity = new_velocity * speed * SPEED_MULTIPLIER

#endregion

#region Game events

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		_shoot_projectile()

func _process(delta: float) -> void:
	if Input.is_action_pressed("Move Up"):
		_look_at(LookAxis.Up)
	elif Input.is_action_pressed("Move Right"):
		_look_at(LookAxis.Right)
	elif Input.is_action_pressed("Move Down"):
		_look_at(LookAxis.Down)
	elif Input.is_action_pressed("Move Left"):
		_look_at(LookAxis.Left)

func _physics_process(delta: float) -> void:
	_move_with_velocity(Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down"))
	move_and_slide()

#endregion
