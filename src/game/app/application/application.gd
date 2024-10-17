class_name Application
extends Node2D

const GameScn = preload("res://game/game.tscn")

enum MissionDifficulty {
	Novice,
	Apprentice,
	Expert
}
			

class MissionDesc:
	var title: String
	var allowed_difficulties: Array[MissionDifficulty]
	var scene: PackedScene
	
	func _init(title: String, allowed_difficulties: Array[MissionDifficulty], scene: PackedScene) -> void:
		self.title = title
		self.allowed_difficulties = allowed_difficulties
		self.scene = scene
		
	func allows_difficulty(difficulty: MissionDifficulty) -> bool:
		return self.allowed_difficulties.find(difficulty) >= 0

class MissionConfig:
	var desc: MissionDesc
	var difficulty: MissionDifficulty
	
	func _init(desc: MissionDesc, difficulty: MissionDifficulty) -> void:
		self.desc = desc
		self.difficulty = difficulty

var all_missions_desc = [
	MissionDesc.new(
		"Tutorial",
		[MissionDifficulty.Novice],
		preload("res://missions/tutorial/tutorial.tscn")
	),
	MissionDesc.new(
		"Hunt for Zorn", 
		[MissionDifficulty.Novice, MissionDifficulty.Apprentice, MissionDifficulty.Expert],
		preload("res://missions/hunt-for-zorn/hunt-for-zorn.tscn")),
	MissionDesc.new(
		"Plain of Koh",
		[MissionDifficulty.Novice, MissionDifficulty.Apprentice, MissionDifficulty.Expert],
		preload("res://missions/plain-of-koh/plain-of-koh.tscn"))
]
var current_game: Game = null

#region Construction

func _ready() -> void:
	$MainMenu.post_ready_process(all_missions_desc)
	
#endregion

#region Game logic

func new_game_with_mission(mission_config: MissionConfig) -> void:
	$MainMenu.hide()
	if current_game != null:
		current_game.queue_free()
	var new_game = GameScn.instantiate()
	add_child(new_game)
	new_game.post_ready_prepare(mission_config)
	new_game.won_mission.connect(_won_mission)
	new_game.retry_mission.connect(_retry_mission)
	new_game.quit_mission.connect(_quit_mission)
	current_game = new_game;
	
func _won_mission() -> void:
	$MainMenu.show()
	current_game.queue_free()
	current_game = null
	
func _retry_mission() -> void:
	$MainMenu.show()
	new_game_with_mission(current_game.mission_config)
	
func _quit_mission() -> void:
	$MainMenu.show()
	current_game.queue_free()
	current_game = null
	
func quit_game() -> void:
	get_tree().quit()

#endregion
