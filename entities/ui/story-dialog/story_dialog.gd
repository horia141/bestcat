@tool
class_name StoryDialog
extends CanvasLayer

signal entered_region_for_trigger ()
signal done ()

enum StoryCheckpoint {
	MissionStart,
	EnterRegion,
	MissionBeatDarkTowers,
	MissionBeatBoss,
	MissionEndFailure,
	MissionEndSuccess
}

@export var message: String = ""
@export var trigger: StoryCheckpoint = StoryCheckpoint.MissionStart

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

#region Game events

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		$Content/Message.text = message
		
#endregion
