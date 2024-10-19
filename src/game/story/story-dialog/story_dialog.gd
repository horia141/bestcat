class_name StoryDialog
extends Dialog

signal done ()

@export var message: String = "":
	get:
		return $Content/Message.text
	set(value):
		$Content/Message.text = value

#region Game logic

func activate() -> void:
	super.activate()
	$Content/Controls/OK.grab_focus()

func _done() -> void:
	done.emit()
	
#endregion
