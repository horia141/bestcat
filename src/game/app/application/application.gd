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
	var ui_name: String
	var ui_description: String
	var scene: PackedScene
	var max_life: int
	var max_speed: int
	var max_projectiles_cnt: int
	
	func _init(
			ui_name: String, 
			ui_description: String,
			scene: PackedScene,
			max_life: int,
			max_speed: int,
			max_projectiles_cnt: int) -> void:
		self.ui_name = ui_name
		self.ui_description = Application.__clean_ui_description(ui_description)
		self.scene = scene
		self.max_life = max_life
		self.max_speed = max_speed
		self.max_projectiles_cnt = max_projectiles_cnt
			

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
		self.ui_description = Application.__clean_ui_description(ui_description)
			

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
		"BestCat",
		"""
			BestCat is the main character in the game and in some comics that will appear.
			
			He is an all around fighter.
		""",
		preload("res://entities/players/bestcat/bestcat.tscn"),
		5,
		5,
		5
	),
	PlayerDesc.new(
		"Kenny",
		"""
			Kenny is BestCat's human.
			
			He's slower than the other players, but packs a punch.
		""",
		preload("res://entities/players/kenny/kenny.tscn"),
		5,
		3,
		7
	),
	PlayerDesc.new(
		"BestDog",
		"""
			BestDog is BestCat's competitor for Kenny's affection (and food)!
			
			BestDog is fast, but he's all bark no bite!
		""",
		preload("res://entities/players/bestdog/bestdog.tscn"),
		4,
		7,
		4
	),
	PlayerDesc.new(
		"Macky",
		"""
			Macky was bought by Kenny when he started farming.
			
			Macky is a bit tougher, but can't do as much damage.
		""",
		preload("res://entities/players/macky/macky.tscn"),
		6,
		5,
		4
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
	
static func __clean_ui_description(desc: String) -> String:
		var elements = desc.split("\n")
		var new_elements: Array[String] = []
		for element in elements:
			new_elements.append(element.strip_edges())
		return "\n".join(new_elements).strip_edges()

#endregion
