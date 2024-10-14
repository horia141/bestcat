class_name PauseMenu
extends CanvasLayer

signal quit_mission ()
signal retry_mission ()

#region Construction

func _ready() -> void:
	pass

#endregion

#region Game logic

func _pause_game() -> void:
	get_tree().paused = true

func _quit_mission() -> void:
	get_tree().paused = false
	quit_mission.emit()
	
func _retry_mission() -> void:
	get_tree().paused = false
	retry_mission.emit()
	
func _resume_mission() -> void:
	get_tree().paused = false
	hide()

#endregion
