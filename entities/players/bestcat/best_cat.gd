class_name BestCat
extends Player

const MAX_LIFE = 5
const MAX_PROJECTILES_CNT = 5
const PROJECTILES_CNT_REGEN_INCREMENT = 1
const PROJECTILES_CNT_REGEN_CUTOFF = 10
const SPEED = 250.0

const PlayerProjectileScn = preload("res://entities/player-projectile/player-projectile.tscn")

var look_right = true
var life = MAX_LIFE
var projectiles_cnt = MAX_PROJECTILES_CNT
var projectiles_cnt_regen_factor = 0.0

#region Construction

func _ready() -> void:
	pass
	
func post_ready_prepare(world_size_in_px: Vector2) -> void:
	$Camera2D.limit_right = world_size_in_px.x
	$Camera2D.limit_bottom = world_size_in_px.y

#endregion

#region Game logic

func _shoot_projectile() -> void:
	if projectiles_cnt == 0:
		return
	var player_projectile = PlayerProjectileScn.instantiate()
	player_projectile.post_ready_prepare(
		position, Vector2(1 if look_right else -1, 0).rotated(randf_range(-0.1, 0.1)))
	shoot.emit(player_projectile)
	projectiles_cnt -= 1
	state_change.emit()
	
func _regen_projectile() -> void:
	if projectiles_cnt == MAX_PROJECTILES_CNT:
		return

	projectiles_cnt_regen_factor += PROJECTILES_CNT_REGEN_INCREMENT
	if projectiles_cnt_regen_factor > PROJECTILES_CNT_REGEN_CUTOFF:
		projectiles_cnt = projectiles_cnt + 1
		projectiles_cnt_regen_factor = 0.0
	
	state_change.emit()

func on_hit_by_projectile() -> void:
	super.on_hit_by_projectile()
	life = life - 1
	
	if life == 0:
		projectiles_cnt = 0
		_destroy()
	
	state_change.emit()
	
func apply_treasure(treasure: Treasure) -> void:
	super.apply_treasure(treasure)
	
	if treasure is LifePowerUp:
		life = min(life + 1, MAX_LIFE)
	elif treasure is ProjectilePowerUp:
		projectiles_cnt = min(projectiles_cnt + 1, MAX_PROJECTILES_CNT)
		projectiles_cnt_regen_factor = 0.0
	else:
		assert(0 == 1, "Invalid treasure: " + str(treasure))
		
	state_change.emit()
	
func _look_at_right(new_look_right: bool) -> void:
	look_right = new_look_right
	$AnimatedSprite2D.flip_h = !look_right
	
func _move_with_velocity(new_velocity: Vector2) -> void:
	velocity = new_velocity * SPEED
		
func _destroy() -> void:
	$AnimatedSprite2D.play("explosion")
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", true)
	await $AnimatedSprite2D.animation_finished
	queue_free()

#endregion

#region Game events

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		_shoot_projectile()

func _process(delta: float) -> void:
	if Input.is_action_pressed("Move Left"):
		_look_at_right(false)
	elif Input.is_action_pressed("Move Right"):
		_look_at_right(true)

func _physics_process(delta: float) -> void:
	_move_with_velocity(Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down"))
	move_and_slide()

#endregion
