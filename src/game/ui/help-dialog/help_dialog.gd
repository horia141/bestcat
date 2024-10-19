class_name HelpDialog
extends Dialog

signal done ()

#region Game logic

func activate() -> void:
	super.activate()
	$Content/Controls/Continue.grab_focus()

func _continue() -> void:
	done.emit()

#endregion
