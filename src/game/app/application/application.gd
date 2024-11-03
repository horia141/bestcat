class_name Application
extends Node2D

const GameScn = preload("res://game/game.tscn")

enum ConceptMode {
	InGame,
	InMainMenu
}

enum MissionDifficulty {
	Novice,
	Apprentice,
	Expert
}

class PlayerDesc:
	var scene: PackedScene
	
	func _init(scene: PackedScene) -> void:
		self.scene = scene
			

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
		
class MissionDifficultyDesc:
	var difficulty: MissionDifficulty
	var ui_name: String
	var ui_description: String
	
	func _init(difficulty: MissionDifficulty, ui_name: String, ui_description: String) -> void:
		self.difficulty = difficulty
		self.ui_name = ui_name
		self.ui_description = __clean_ui_description(ui_description)
		
	static func __clean_ui_description(desc: String) -> String:
		var elements = desc.split("\n")
		var new_elements: Array[String] = []
		for element in elements:
			new_elements.append(element.strip_edges())
		return "\n".join(new_elements)
			

class MissionAttempt:
	var player: PlayerDesc
	var mission: MissionDesc
	var difficulty: MissionDifficultyDesc
	
	func _init(player: PlayerDesc, mission: MissionDesc, difficulty: MissionDifficultyDesc) -> void:
		self.player = player
		self.mission = mission
		self.difficulty = difficulty
		
var all_players_desc: Array[PlayerDesc] = [
	PlayerDesc.new(
		preload("res://entities/players/bestcat/bestcat.tscn")
	),
	PlayerDesc.new(
		preload("res://entities/players/kenny/kenny.tscn")
	),
	PlayerDesc.new(
		preload("res://entities/players/bestdog/bestdog.tscn")
	),
	PlayerDesc.new(
		preload("res://entities/players/macky/macky.tscn")
	)
]

var all_missions_desc: Array[MissionDesc] = [
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

var all_mission_difficulties_desc: Array[MissionDifficultyDesc] = [
	MissionDifficultyDesc.new(
		MissionDifficulty.Novice,
		"Novice",
		"""
			Novice difficulty is for new players to the game.
			
			Try this for a relaxing approach to the game.
			
			* Dark towers generate few enemies.
			* Mobs shoot infrequently.
			* Final bosses are approachable.
		"""
	),
	MissionDifficultyDesc.new(
		MissionDifficulty.Apprentice,
		"Apprentice",
		"""
			Apprentice difficulty is for those that have spent some time with the game.
			
			Try this for a balanced approach to the game.
			
			* Dark towers generate a good amount of enemies.
			* Mobs shoot frequently.
			* Final bosses are tough.
		"""
	),
	MissionDifficultyDesc.new(
		MissionDifficulty.Expert,
		"Expert",
		"""
			Expert difficulty is for those that want a real challange.
			
			Try this for an uphill battle against the game.
			
			* Dark towers generate many enemies.
			* Mobs shoot frequently.
			* Final bosses are legendary.
		"""
	)
]

var current_game: Game = null

#region Construction

func _ready() -> void:
	$MainMenu.post_ready_process(all_players_desc, all_missions_desc, all_mission_difficulties_desc)
	
#endregion

#region Game logic

func new_game_with_mission_attempt(mission_attempt: MissionAttempt) -> void:
	$MainMenu.hide()
	if current_game != null:
		current_game.queue_free()
	var new_game = GameScn.instantiate()
	add_child(new_game)
	new_game.post_ready_prepare(mission_attempt)
	new_game.won_mission.connect(_won_mission)
	new_game.retry_mission.connect(_retry_mission)
	new_game.quit_mission.connect(_quit_mission)
	current_game = new_game;
	
func _won_mission() -> void:
	$MainMenu.activate()
	current_game.queue_free()
	current_game = null
	
func _retry_mission() -> void:
	$MainMenu.activate()
	new_game_with_mission_attempt(current_game.mission_attempt)
	
func _quit_mission() -> void:
	$MainMenu.activate()
	current_game.queue_free()
	current_game = null
	
func quit_game() -> void:
	get_tree().quit()

#endregion
