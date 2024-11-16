class_name MobileControls
extends Node2D

#region Construction

func _ready() -> void:
	match OS.get_name():
		["Android", "iOS"]:
			show()
		"Web":
			hide()
		_:
			hide()
	
#region

#region Game logic

func _on_shoot_press() -> void:
	var input_event = InputEventAction.new()
	input_event.action = "Shoot"
	input_event.pressed = true
	Input.parse_input_event(input_event)

func _on_move_up_press() -> void:
	var input_event = InputEventAction.new()
	input_event.action = "Move Up"
	input_event.pressed = true
	Input.parse_input_event(input_event)
	await get_tree().create_timer(0.1).timeout
	var input_event_clear = InputEventAction.new()
	input_event_clear.action = "Move Up"
	input_event_clear.pressed = false
	Input.parse_input_event(input_event_clear)

func _on_move_right_press() -> void:
	var input_event = InputEventAction.new()
	input_event.action = "Move Right"
	input_event.pressed = true
	Input.parse_input_event(input_event)
	await get_tree().create_timer(0.1).timeout
	var input_event_clear = InputEventAction.new()
	input_event_clear.action = "Move Right"
	input_event_clear.pressed = false
	Input.parse_input_event(input_event_clear)

func _on_move_down_press() -> void:
	var input_event = InputEventAction.new()
	input_event.action = "Move Down"
	input_event.pressed = true
	Input.parse_input_event(input_event)
	await get_tree().create_timer(0.1).timeout
	var input_event_clear = InputEventAction.new()
	input_event_clear.action = "Move Down"
	input_event_clear.pressed = false
	Input.parse_input_event(input_event_clear)

func _on_move_left_press() -> void:
	var input_event = InputEventAction.new()
	input_event.action = "Move Left"
	input_event.pressed = true
	Input.parse_input_event(input_event)
	await get_tree().create_timer(0.1).timeout
	var input_event_clear = InputEventAction.new()
	input_event_clear.action = "Move Left"
	input_event_clear.pressed = false
	Input.parse_input_event(input_event_clear)

#endregion
