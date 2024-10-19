class_name PauseMenu
extends Dialog

signal quit_mission ()
signal retry_mission ()
signal resume_mission ()

#region Game logic

func activate() -> void:
	super.activate()
	$Controls/Resume.grab_focus()

func _quit_mission() -> void:
	quit_mission.emit()
	
func _retry_mission() -> void:
	retry_mission.emit()
	
func _resume_mission() -> void:
	resume_mission.emit()

#endregion
