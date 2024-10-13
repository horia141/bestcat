class_name HelpDialog
extends CanvasLayer

signal done ()

#region Game logic

func _continue() -> void:
	done.emit()

#endregion
