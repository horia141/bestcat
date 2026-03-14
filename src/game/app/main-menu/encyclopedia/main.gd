class_name EncyclopediaMain
extends VBoxContainer

signal return_from()

#region Construction

#endregion

#region Game logic

func activate() -> void:
	show()
	$Controls/Margin/Return.grab_focus()
	
func deactivate() -> void:
	hide()
	
func _return_from() -> void:
	return_from.emit()

#endregion
