class_name Application
extends Node2D

const GameScn = preload("res://entities/game/game.tscn")

var current_game = null;

#region Construction

func _ready() -> void:
	pass
	
#endregion

#region Game logic

func new_game(mission_path: String) -> void:
	$MainMenu.hide()
	if current_game != null:
		current_game.queue_free()
	var new_game = GameScn.instantiate()
	add_child(new_game)
	new_game.post_ready_prepare(mission_path)
	new_game.quit_mission.connect(_quit_mission)
	current_game = new_game;
	
func _quit_mission() -> void:
	$MainMenu.show()
	current_game.queue_free();
	current_game = null;
	
func quit_game() -> void:
	get_tree().quit()

#endregion
