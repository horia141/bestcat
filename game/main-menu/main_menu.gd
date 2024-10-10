class_name MainMenu
extends CanvasLayer

#region Construction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
#endregion

#region Game logic

func _new_game() -> void:
	get_tree().change_scene_to_file("res://entities/game/game.tscn")

func _quit_game() -> void:
	get_tree().quit()
	
#endregion
