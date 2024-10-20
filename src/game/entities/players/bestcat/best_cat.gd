class_name BestCat
extends Player

static var MAX_LIFE = DifficultyValue.new(7, 5, 3)
static var MAX_PROJECTILES_CNT = DifficultyValue.new(7, 5, 3)
const PROJECTILES_CNT_REGEN_INCREMENT = 1
static var PROJECTILES_CNT_REGEN_CUTOFF = DifficultyValue.new(5, 10, 15)
static var SPEED = DifficultyValue.new(300.0, 250.0, 200.0)

const PlayerProjectileScn = preload("res://entities/player-projectile/player-projectile.tscn")

enum LookAxis {
	Up,
	Right,
	Down,
	Left
}

var look_axis: LookAxis = LookAxis.Right
var look_right: bool = true
var life = MAX_LIFE.get_for(difficulty)
var projectiles_cnt = MAX_PROJECTILES_CNT.get_for(difficulty)
var projectiles_cnt_regen_factor = 0.0

#region Construction

func _ready() -> void:
	pass
	
func post_ready_prepare(init_position: Vector2, difficulty: Application.MissionDifficulty) -> void:
	super.post_ready_prepare(init_position, difficulty)
	life = MAX_LIFE.get_for(difficulty)
	projectiles_cnt = MAX_PROJECTILES_CNT.get_for(difficulty)

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

func on_hit_by_projectile() -> void:
	super.on_hit_by_projectile()
	
	if state == PlayerState.Dead:
		return

	life = max(life - 1, 0)
	
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
	super.apply_treasure(treasure)
	
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

	velocity = new_velocity * SPEED.get_for(difficulty)

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
