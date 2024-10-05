class_name BestCat
extends Player

const MAX_LIFE = 5
const SPEED = 250.0

const PlayerProjectileScn = preload("res://entities/player-projectile/player-projectile.tscn")

var look_right = true
var life = MAX_LIFE

#region Construction

func _on_ready() -> void:
	pass
	
func post_ready_prepare(world_size_in_px: Vector2) -> void:
	$Camera2D.limit_right = world_size_in_px.x
	$Camera2D.limit_bottom = world_size_in_px.y

#endregion

#region Game logic

func _shoot_projectile() -> void:
	var player_projectile = PlayerProjectileScn.instantiate()
	player_projectile.post_ready_prepare(
		position, Vector2(1 if look_right else -1, 0).rotated(randf_range(-0.1, 0.1)))
	shoot.emit(player_projectile)

func on_hit_by_projectile() -> void:
	super.on_hit_by_projectile()
	life = life - 1
	
	if life == 0:
		$AnimatedSprite2D.play("explosion")
		$CollisionShape2D.set_deferred("disabled", true)
		set_deferred("freeze", true)
	
func __on_animated_sprite_2d_animation_finished() -> void:
	# If we've triggered this animation, we exploded! Let's remove this!
	if $AnimatedSprite2D.animation == "explosion":
		queue_free()
		
func _look_at_right(new_look_right: bool) -> void:
	look_right = new_look_right
	$AnimatedSprite2D.flip_h = !look_right
	
func _move_with_velocity(new_velocity: Vector2) -> void:
	velocity = new_velocity * SPEED

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
