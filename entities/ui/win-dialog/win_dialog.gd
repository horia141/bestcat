class_name WinDialog
extends CanvasLayer

signal continue_after_winning ()

#region Construction

func _ready() -> void:
	pass
	
#endregion

#region Game logic

func _continue() -> void:
	continue_after_winning.emit()

#endregion
