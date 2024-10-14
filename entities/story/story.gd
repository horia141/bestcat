class_name Story
extends Node

enum StoryCheckpoint {
	MissionStart,
	EnterRegion,
	MissionBeatDarkTowers,
	MissionBeatBoss,
	MissionEndFailure,
	MissionEndSuccess
}

signal story_checkpoint_processed(checkpoint: StoryCheckpoint)

@export_group("Mission Start", "mission_start_")
@export_multiline var mission_start_messages: Array[String]

@export_group("Mission Beat Dark Towers", "mission_beat_dark_towers_")
@export_multiline var mission_beat_dark_towers_messages: Array[String]

@export_group("Mission Beat Boss", "mission_beat_boss_")
@export_multiline var mission_beat_boss_messages: Array[String]

@export_group("Mission End Failure", "mission_end_failure_")
@export_multiline var mission_end_failure_messages: Array[String]

@export_group("Mission End Success", "mission_end_success_")
@export_multiline var mission_end_success_messages: Array[String]

#region Construction

func _ready() -> void:
	$StoryDialog.hide()

#endregion

#region Game logic

func advance_to_story_checkpoint(checkpoint: StoryCheckpoint) -> void:
	var processed_message = false
			
	match checkpoint:
		StoryCheckpoint.MissionStart:
			for message in mission_start_messages:
				$StoryDialog.show()
				$StoryDialog.message = message
				await $StoryDialog.done
				$StoryDialog.hide()
				processed_message = true
		StoryCheckpoint.MissionBeatDarkTowers:
			for message in mission_beat_dark_towers_messages:
				$StoryDialog.show()
				$StoryDialog.message = message
				await $StoryDialog.done
				$StoryDialog.hide()
				processed_message = true
		StoryCheckpoint.MissionBeatBoss:
			for message in mission_beat_boss_messages:
				$StoryDialog.show()
				$StoryDialog.message = message
				await $StoryDialog.done
				$StoryDialog.hide()
				processed_message = true
		StoryCheckpoint.MissionEndFailure:
			for message in mission_end_failure_messages:
				$StoryDialog.show()
				$StoryDialog.message = message
				await $StoryDialog.done
				$StoryDialog.hide()
				processed_message = true
		StoryCheckpoint.MissionEndSuccess:
			for message in mission_end_success_messages:
				$StoryDialog.show()
				$StoryDialog.message = message
				await $StoryDialog.done
				$StoryDialog.hide()
				processed_message = true
				
	if not processed_message:
		# If we have not shown the dialog at all we need to
		# skip a beat & still suspend execution somehow. Somebody
		# might be waiting on our signal, and if we don't wait
		# explicitly, the emit will trigger immediately. Which means
		# any `await` code that comes immediately after the call
		# to this method will hand indefinitely.
		await get_tree().process_frame
		
	story_checkpoint_processed.emit(checkpoint)
			
#endregion
