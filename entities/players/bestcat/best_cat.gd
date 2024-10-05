class_name BestCat
extends CharacterBody2D

signal shoot

const SPEED = 250.0

var look_right = true
var life = 5

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		var player_projectile_scn = preload("res://entities/player-projectile/player-projectile.tscn")
		var player_projectile = player_projectile_scn.instantiate()
		player_projectile.post_ready_prepare(
			position, Vector2(1 if look_right else -1, 0).rotated(randf_range(-0.1, 0.1)))
		shoot.emit(player_projectile)
		

func _process(delta: float) -> void:
	if Input.is_action_pressed("Move Left"):
		look_right = false
		$AnimatedSprite2D.flip_h = true
	elif Input.is_action_pressed("Move Right"):
		look_right = true
		$AnimatedSprite2D.flip_h = false
		

func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity = input_direction * SPEED

	move_and_slide()
	

func post_ready_prepare(world_size_in_px: Vector2) -> void:
	$Camera2D.limit_right = world_size_in_px.x
	$Camera2D.limit_bottom = world_size_in_px.y
	

func on_hit_by_projectile() -> void:
	life = life - 1
	
	if life == 0:
		queue_free()
