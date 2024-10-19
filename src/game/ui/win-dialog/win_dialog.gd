class_name WinDialog
extends Dialog

signal continue_after_winning ()

#region Game logic

func activate() -> void:
	super.activate()
	$Contents/Controls/Continue.grab_focus()

func _continue() -> void:
	continue_after_winning.emit()

#endregion
