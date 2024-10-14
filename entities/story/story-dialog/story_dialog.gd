class_name StoryDialog
extends CanvasLayer

signal done ()

@export var message: String = "":
	get:
		return $Content/Message.text
	set(value):
		$Content/Message.text = value

#region Construction

func _init() -> void:
	pass

func _ready() -> void:
	pass

#endregion

#region Game logic

func _done() -> void:
	done.emit()
	
#endregion
