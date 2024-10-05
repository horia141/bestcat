extends CharacterBody2D

signal shoot

const SPEED = 250.0

var look_right = true
var life = 5

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		var input_direction_clean = Vector2(1 if look_right else -1, 0)
		var input_direction_jitter = randf_range(-0.1, 0.1)
		var input_direction = input_direction_clean.rotated(input_direction_jitter)
		var projectile_scene = preload("res://entities/projectile/projectile.tscn")
		var projectile = projectile_scene.instantiate()
		projectile.position = position + 32 * input_direction
		projectile.add_constant_central_force(1000 * input_direction)
		shoot.emit(projectile)
		

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
	

func on_hit_by_projectile() -> void:
	life = life - 1
	
	if life == 0:
		queue_free()
