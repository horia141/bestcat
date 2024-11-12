class_name HelpDialog
extends Dialog

signal done ()

#region Game logic

func activate() -> void:
	super.activate()
	$Content/Controls/Margin/Layout/Continue.grab_focus()
	
func deactivate() -> void:
	hide()

func _continue() -> void:
	done.emit()

#endregion
