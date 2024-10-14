class_name StoryManager
extends Node

signal story_checkpoint_processed(checkpoint: StoryDialog.StoryCheckpoint)

#region Construction

func _init() -> void:
	pass
	
func _ready() -> void:
	pass
	
func post_ready_prepare() -> void:
	for story_dialog in get_tree().get_nodes_in_group("Story Dialogs"):
		var the_story_dialog = story_dialog as StoryDialog
		the_story_dialog.hide()
		# the_story_dialog.triggered.connect(func (): _story_point_triggered(the_story_dialog))

#endregion

#region Game logic

func advance_to_story_checkpoint(checkpoint: StoryDialog.StoryCheckpoint) -> void:
	for story_dialog in get_tree().get_nodes_in_group("Story Dialogs"):
		var the_story_dialog = story_dialog as StoryDialog
		if story_dialog.trigger == checkpoint:
			story_dialog.show()
			await story_dialog.done
			story_dialog.hide()
			story_checkpoint_processed.emit(checkpoint)
			return


#endregion
