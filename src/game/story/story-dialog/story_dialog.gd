class_name StoryDialog
extends Dialog

signal done ()

@export var message: String = "":
	get:
		return $Frame/Margin/Layout/Content/Margin/Message.text
	set(value):
		$Frame/Margin/Layout/Content/Margin/Message.text = value

#region Game logic

func activate() -> void:
	super.activate()
	$Frame/Margin/Layout/OK.grab_focus()

func _done() -> void:
	done.emit()
	
#endregion
