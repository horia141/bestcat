extends CharacterBody2D

signal shoot

const SPEED = 250.0

@export var look_right = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		shoot.emit()
		

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
