extends CharacterBody2D

const SPEED = 250.0


func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity = input_direction * SPEED

	move_and_slide()
