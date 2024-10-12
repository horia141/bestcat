class_name Application
extends Node2D

const GameScn = preload("res://entities/game/game.tscn")

class MissionDesc:
	var title: String
	var scene: PackedScene
	
	func _init(title: String, scene: PackedScene) -> void:
		self.title = title
		self.scene = scene

var all_missions_desc = [
	MissionDesc.new("Tutorial", preload("res://entities/missions/tutorial/tutorial.tscn")),
	MissionDesc.new("Plain of Koh", preload("res://entities/missions/plain-of-koh/plain-of-koh.tscn"))
]
var current_game = null

#region Construction

func _ready() -> void:
	$MainMenu.post_ready_process(all_missions_desc)
	
#endregion

#region Game logic

func new_game_with_mission(mission_desc: MissionDesc) -> void:
	$MainMenu.hide()
	if current_game != null:
		current_game.queue_free()
	var new_game = GameScn.instantiate()
	add_child(new_game)
	new_game.post_ready_prepare(mission_desc)
	new_game.quit_mission.connect(_quit_mission)
	current_game = new_game;
	
func _quit_mission() -> void:
	$MainMenu.show()
	current_game.queue_free();
	current_game = null;
	
func quit_game() -> void:
	get_tree().quit()

#endregion
