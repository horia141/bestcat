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
		
		
class PlayerWeaponDesc:
	var ui_name: String
	var ui_description: String
	var scene: PackedScene
	var max_ammo: int
	var damage: int
	var range: float
	var speed: float
	var accuracy: float
	var reload_speed: float
	
	func _init(
		ui_name: String,
		ui_description: String,
		scene: PackedScene,
		max_ammo: int,
		damage: int,
		range: float,
		speed: float,
		accuracy: float,
		reload_speed: float
	) -> void:
		self.ui_name = ui_name
		self.ui_description = Application.__clean_ui_description(ui_description)
		self.scene = scene
		self.max_ammo = max_ammo
		self.damage = damage
		self.range = range
		self.accuracy = accuracy
		self.reload_speed = reload_speed
		
class EnemyDesc:
	var ui_name: String
	var ui_description: String
	var scene: PackedScene
	var max_life: DifficultyValue
	
	func _init(
		ui_name: String,
		ui_description: String,
		scene: PackedScene,
		max_life: DifficultyValue
	) -> void:
		self.ui_name = ui_name
		self.ui_description = Application.__clean_ui_description(ui_description)
		self.scene = scene
		self.max_life = max_life

class MissionDesc:
	var title: String
	var ui_description: String
	var size: Mission.MapSize
	var challenge: Mission.Challenge
	var allowed_difficulties: Array[MissionDifficulty]
	var scene: PackedScene
	
	func _init(
		title: String, ui_description: String, size: Mission.MapSize, challenge: Mission.Challenge,
		allowed_difficulties: Array[MissionDifficulty], scene: PackedScene) -> void:
		self.title = title
		self.ui_description = Application.__clean_ui_description(ui_description)
		self.size = size
		self.challenge = challenge
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

class PlayerInMission:
	var player: PlayerDesc
	var weapon: PlayerWeaponDesc
	
	func _init(
		player: PlayerDesc,
		weapon: PlayerWeaponDesc,
	) -> void:
		self.player = player
		self.weapon = weapon

class MissionAttempt:
	var player_in_mission: PlayerInMission
	var mission: MissionDesc
	var difficulty: MissionDifficultyDesc
	var all_mobs_desc: Array[EnemyDesc]
	var all_bosses_desc: Array[EnemyDesc]
	
	func _init(
		player_in_mission: PlayerInMission, mission: MissionDesc, 
		difficulty: MissionDifficultyDesc, all_mobs_desc: Array[EnemyDesc], 
		all_bosses_desc: Array[EnemyDesc]) -> void:
		self.player_in_mission = player_in_mission
		self.mission = mission
		self.difficulty = difficulty
		self.all_mobs_desc = all_mobs_desc
		self.all_bosses_desc = all_bosses_desc
		
var all_players_desc: Array[PlayerDesc] = [
	BestCat.Desc,
	Kenny.Desc,
	BestDog.Desc,
	Macky.Desc
]

var all_player_weapons_desc: Array[PlayerWeaponDesc] = [
	MagicWand.Desc,
	RubyStaff.Desc,
	TopazStaff.Desc,
	SapphireStaff.Desc,
	EmeraldStaff.Desc
]

var all_mobs_desc: Array[EnemyDesc] = [
	Jelly.Desc,
	Ogre.Desc,
	Snail.Desc,
	Rocker.Desc
]

var all_bosses_desc: Array[EnemyDesc] = [
	StoneKiller.Desc,
	Zorax.Desc
]

var all_missions_desc: Array[MissionDesc] = [
	Tutorial.Desc,
	HuntForZorn.Desc,
	PlainOfKoh.Desc,
	TheLabyrinthOfUntash.Desc
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
			Expert difficulty is for those that want a real challenge.
			
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
	$MainMenu.post_ready_process(all_players_desc, all_player_weapons_desc, all_missions_desc, all_mission_difficulties_desc, all_mobs_desc, all_bosses_desc)
	
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
