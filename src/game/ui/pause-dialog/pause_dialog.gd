class_name PauseMenu
extends CanvasLayer

signal quit_mission ()
signal retry_mission ()
signal resume_mission ()

#region Construction

func _ready() -> void:
	pass

#endregion

#region Game logic

func _quit_mission() -> void:
	quit_mission.emit()
	
func _retry_mission() -> void:
	retry_mission.emit()
	
func _resume_mission() -> void:
	resume_mission.emit()

#endregion
