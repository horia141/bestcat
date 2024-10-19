class_name Story
extends Node

enum StoryCheckpoint {
	EnemyDestroyed,
	PlayerEntersRegion,
	MissionStart,
	MissionBeatDarkTowers,
	MissionBeatBoss,
	MissionEndFailure,
	MissionEndSuccess
}

signal story_checkpoint_processed(checkpoint: StoryCheckpoint)

@export_group("Enemy Destroyed", "enemy_destroy_")
@export_multiline var enemy_destroy_messages: Array[String]
@export_node_path("Enemy") var enemy_destroy_nodes: Array[NodePath]

@export_group("Player Enters Region", "player_enters_region_")
@export_multiline var player_enters_region_messages: Array[String]
@export_node_path("StoryTriggerArea") var player_enters_region_nodes: Array[NodePath]

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
	assert(len(enemy_destroy_messages) == len(enemy_destroy_nodes), "Should have one message for every enemy to destroy")
	
	var enemy_destroy_idx = 0
	for enemy_destroy_node_path in enemy_destroy_nodes:
		var enemy_destroy_message = enemy_destroy_messages[enemy_destroy_idx]
		var enemy = get_node(enemy_destroy_node_path) as Enemy
		enemy.destroyed.connect(func (): _trigger_enemy_destroyed_story_checkpoint(enemy, enemy_destroy_message))
		enemy_destroy_idx += 1
		
	assert(len(player_enters_region_messages) == len(player_enters_region_nodes), "Should have one message for every region trigger")
	
	var player_enter_region_idx = 0
	for player_enters_region_node_path in player_enters_region_nodes:
		var player_enters_region_message = player_enters_region_messages[player_enter_region_idx]
		var story_trigger_area = get_node(player_enters_region_node_path) as StoryTriggerArea
		story_trigger_area.player_entered.connect(func (): _trigger_player_enters_region_checkpoint(player_enters_region_message))
		player_enter_region_idx += 1
	
	$StoryDialog.hide()

#endregion

#region Game logic

func advance_to_story_checkpoint(checkpoint: StoryCheckpoint) -> void:
	var processed_message = false
	
	match checkpoint:
		StoryCheckpoint.MissionStart:
			for message in mission_start_messages:
				$StoryDialog.activate()
				$StoryDialog.message = message
				await $StoryDialog.done
				$StoryDialog.hide()
				processed_message = true
		StoryCheckpoint.MissionBeatDarkTowers:
			for message in mission_beat_dark_towers_messages:
				$StoryDialog.activate()
				$StoryDialog.message = message
				await $StoryDialog.done
				$StoryDialog.hide()
				processed_message = true
		StoryCheckpoint.MissionBeatBoss:
			for message in mission_beat_boss_messages:
				$StoryDialog.activate()
				$StoryDialog.message = message
				await $StoryDialog.done
				$StoryDialog.hide()
				processed_message = true
		StoryCheckpoint.MissionEndFailure:
			for message in mission_end_failure_messages:
				$StoryDialog.activate()
				$StoryDialog.message = message
				await $StoryDialog.done
				$StoryDialog.hide()
				processed_message = true
		StoryCheckpoint.MissionEndSuccess:
			for message in mission_end_success_messages:
				$StoryDialog.activate()
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
	
func _trigger_enemy_destroyed_story_checkpoint(enemy: Enemy, message: String) -> void:
	get_tree().paused = true
	$StoryDialog.activate()
	$StoryDialog.message = message
	await $StoryDialog.done
	$StoryDialog.hide()
	get_tree().paused = false
	
	story_checkpoint_processed.emit(StoryCheckpoint.EnemyDestroyed)
	
func _trigger_player_enters_region_checkpoint(message: String) -> void:
	get_tree().paused = true
	$StoryDialog.activate()
	$StoryDialog.message = message
	await $StoryDialog.done
	$StoryDialog.hide()
	get_tree().paused = false
	
	story_checkpoint_processed.emit(StoryCheckpoint.PlayerEntersRegion)
			
#endregion
