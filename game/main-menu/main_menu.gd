class_name MainMenu
extends CanvasLayer

signal new_game (mission_desc: Application.MissionDesc)
signal quit_game ()

enum View {
	Main,
	SelectMission
}

var view = View.Main

#region Construction

func _ready() -> void:
	_show()
	
func post_ready_process(all_missions_desc: Array) -> void:
	for mission_desc_r in all_missions_desc:
		var mission_desc = mission_desc_r as Application.MissionDesc
		var mission_button = Button.new()
		mission_button.text = mission_desc.title
		mission_button.button_up.connect(func (): _new_game(mission_desc))
		mission_button.add_theme_font_size_override("font_size", 36)
		$SelectMission.add_child(mission_button)
	

#region Game logic

func _new_game_go_to_select_mission() -> void:
	view = View.SelectMission
	_show()
	
func _select_mission_to_main() -> void:
	view = View.Main
	_show()
	
func _new_game(mission_desc: Application.MissionDesc) -> void:
	new_game.emit(mission_desc)
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
