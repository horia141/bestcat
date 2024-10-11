class_name MainMenu
extends CanvasLayer

signal new_game (mission_path: String)
signal quit_game ()

enum View {
	Main,
	SelectMission
}

var view = View.Main
var all_missions_desc = [
	["Tutorial", "res://entities/missions/tutorial/tutorial.tscn"],
	["Plain Of Koh", "res://entities/missions/plain-of-koh/plain-of-koh.tscn"]
]

#region Construction

func _ready() -> void:
	for mission_desc in all_missions_desc:
		var mission_button = Button.new()
		mission_button.text = mission_desc[0]
		mission_button.button_up.connect(func (): _new_game(mission_desc[1]))
		$SelectMission.add_child(mission_button)
	_show()

#region Game logic

func _new_game_go_to_select_mission() -> void:
	view = View.SelectMission
	_show()
	
func _select_mission_to_main() -> void:
	view = View.Main
	_show()
	
func _new_game(mission: String) -> void:
	new_game.emit(mission)
	view = View.Main
	_show()

func _quit_game() -> void:
	quit_game.emit()
	
func _show() -> void:
	match view:
		View.Main:
			$Main.show()
			$SelectMission.hide()
		View.SelectMission:
			$Main.hide()
			$SelectMission.show()
			
			
#endregion
