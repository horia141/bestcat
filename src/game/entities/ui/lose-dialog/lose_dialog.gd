class_name LoseDialog
extends CanvasLayer

signal retry_mission ()
signal quit_mission ()

#region Construction

func _ready() -> void:
	pass
	
#endregion

#region Game logic

func _retry() -> void:
	retry_mission.emit()
	
func _quit() -> void:
	quit_mission.emit()

#endregion
