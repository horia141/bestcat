class_name PauseMenu
extends CanvasLayer

#region Construction

func _ready() -> void:
	pass

#endregion

#region Game logic

func _pause_game() -> void:
	get_tree().paused = true
	show()

func _quit_mission() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/main-menu/main-menu.tscn")
	
func _resume_mission() -> void:
	get_tree().paused = false
	hide()

#endregion

#region Game events

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Mission Pause"):
		_pause_game()

#endregion
