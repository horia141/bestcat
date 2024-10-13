class_name MainMenu
extends CanvasLayer

signal new_game (mission_config: Application.MissionConfig)
signal quit_game ()

enum View {
	Main,
	SelectMission,
	SelectDifficulty,
	Controls
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
		mission_button.button_up.connect(func (): _select_mission_go_to_select_difficulty(mission_desc))
		mission_button.add_theme_font_size_override("font_size", 36)
		$SelectMission.add_child(mission_button)
	

#region Game logic

func _main_go_to_select_mission() -> void:
	view = View.SelectMission
	_show()
	
func _select_mission_to_main() -> void:
	view = View.Main
	_show()
	
func _select_mission_go_to_select_difficulty(mission_desc: Application.MissionDesc) -> void:
	view = View.SelectDifficulty
	$SelectDifficulty/Novice.disabled = !mission_desc.allows_difficulty(Application.MissionDifficulty.Novice)
	$SelectDifficulty/Novice.button_up.connect(func (): _new_game(mission_desc, Application.MissionDifficulty.Novice))
	$SelectDifficulty/Apprentice.disabled = !mission_desc.allows_difficulty(Application.MissionDifficulty.Apprentice)
	$SelectDifficulty/Apprentice.button_up.connect(func (): _new_game(mission_desc, Application.MissionDifficulty.Apprentice))
	$SelectDifficulty/Expert.disabled = !mission_desc.allows_difficulty(Application.MissionDifficulty.Expert)
	$SelectDifficulty/Expert.button_up.connect(func (): _new_game(mission_desc, Application.MissionDifficulty.Expert))
	_show()
	
func _select_difficulty_go_to_select_mission() -> void:
	view = View.SelectMission
	for conn in $SelectDifficulty/Novice.button_up.get_connections():
		$SelectDifficulty/Novice.button_up.disconnect(conn["callable"])
	for conn in $SelectDifficulty/Apprentice.button_up.get_connections():
		$SelectDifficulty/Apprentice.button_up.disconnect(conn["callable"])
	for conn in $SelectDifficulty/Expert.button_up.get_connections():
		$SelectDifficulty/Expert.button_up.disconnect(conn["callable"])
	_show()
	
func _main_to_controls() -> void:
	view = View.Controls
	_show()
	
func _controls_to_main() -> void:
	view = View.Main
	_show()
	
func _new_game(mission_desc: Application.MissionDesc, difficulty: Application.MissionDifficulty) -> void:
	var mission_config = Application.MissionConfig.new(mission_desc, difficulty)
	new_game.emit(mission_config)
	view = View.Main
	_show()

func _quit_game() -> void:
	quit_game.emit()
	
func _show() -> void:
	match view:
		View.Main:
			$Main.show()
			$SelectMission.hide()
			$SelectDifficulty.hide()
			$HelpDialog.hide()
		View.SelectMission:
			$Main.hide()
			$SelectMission.show()
			$SelectDifficulty.hide()
			$HelpDialog.hide()
		View.SelectDifficulty:
			$Main.hide()
			$SelectMission.hide()
			$SelectDifficulty.show()
			$HelpDialog.hide()
		View.Controls:
			$Main.hide()
			$SelectMission.hide()
			$SelectDifficulty.hide()
			$HelpDialog.show()
			
			
#endregion
