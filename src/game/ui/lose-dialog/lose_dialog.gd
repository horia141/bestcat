class_name LoseDialog
extends Dialog

signal retry_mission ()
signal quit_mission ()

#region Game logic

func activate() -> void:
	super.activate()
	$Content/Controls/Retry.grab_focus()

func _retry() -> void:
	retry_mission.emit()
	
func _quit() -> void:
	quit_mission.emit()

#endregion
