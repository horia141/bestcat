class_name MainMenu
extends CanvasLayer

signal new_game (mission_attempt: Application.MissionAttempt)
signal quit_game ()

enum View {
	Main,
	SelectMission,
	SelectPlayer,
	SelectDifficulty,
	Controls
}

var view = View.Main

var selected_player: Application.PlayerDesc = null
var selected_mission: Application.MissionDesc = null
var selected_difficulty: Application.MissionDifficulty = Application.MissionDifficulty.Apprentice

#region Construction

func _ready() -> void:
	_show()
	
func post_ready_process(all_players_desc: Array[Application.PlayerDesc], all_missions_desc: Array[Application.MissionDesc]) -> void:
	$SelectPlayer.post_ready_prepare(all_players_desc)

	for mission_desc in all_missions_desc:
		var mission_button = Button.new()
		mission_button.text = mission_desc.title
		mission_button.button_up.connect(func (): _select_mission_go_to_select_player(mission_desc))
		mission_button.add_theme_font_size_override("font_size", 36)
		$SelectMission.add_child(mission_button)
		
	$SelectDifficulty/Novice.button_up.connect(func (): _select_difficulty_go_to_new_game(Application.MissionDifficulty.Novice))
	$SelectDifficulty/Apprentice.button_up.connect(func (): _select_difficulty_go_to_new_game(Application.MissionDifficulty.Apprentice))
	$SelectDifficulty/Expert.button_up.connect(func (): _select_difficulty_go_to_new_game(Application.MissionDifficulty.Expert))
	

	_show()
	

#region Game logic

func activate() -> void:
	show()
	_show()
	
func _main_go_to_select_mission() -> void:
	view = View.SelectMission
	_show()
	
func _main_go_to_quit_game() -> void:
	quit_game.emit()
	
func _select_mission_go_to_select_player(mission_desc: Application.MissionDesc) -> void:
	selected_mission = mission_desc
	view = View.SelectPlayer
	_show()
	
func _select_mission_to_main() -> void:
	view = View.Main
	_show()

func _select_player_go_to_select_difficulty(player_desc: Application.PlayerDesc) -> void:
	selected_player = player_desc
	view = View.SelectDifficulty	
	$SelectDifficulty/Novice.disabled = !selected_mission.allows_difficulty(Application.MissionDifficulty.Novice)
	$SelectDifficulty/Apprentice.disabled = !selected_mission.allows_difficulty(Application.MissionDifficulty.Apprentice)
	$SelectDifficulty/Expert.disabled = !selected_mission.allows_difficulty(Application.MissionDifficulty.Expert)
	_show()
	
func _select_player_go_to_select_mission() -> void:
	view = View.SelectMission
	_show()
	
func _select_difficulty_go_to_new_game(difficulty: Application.MissionDifficulty) -> void:
	var mission_attempt = Application.MissionAttempt.new(selected_player, selected_mission, difficulty)
	new_game.emit(mission_attempt)
	view = View.Main
	_show()
	
func _select_difficulty_go_to_select_player() -> void:
	view = View.SelectPlayer
	_show()
	
func _main_to_controls() -> void:
	view = View.Controls
	_show()
	
func _controls_to_main() -> void:
	view = View.Main
	_show()
	
func _show() -> void:
	match view:
		View.Main:
			$Main.show()
			$SelectMission.hide()
			$SelectPlayer.hide()
			$SelectDifficulty.hide()
			$HelpDialog.hide()
			$Main/NewGame.grab_focus()
		View.SelectMission:
			$Main.hide()
			$SelectMission.show()
			$SelectPlayer.hide()
			$SelectDifficulty.hide()
			$HelpDialog.hide()
			$SelectMission/Return.grab_focus()
		View.SelectPlayer:
			$Main.hide()
			$SelectMission.hide()
			$SelectPlayer.activate()
			$SelectDifficulty.hide()
			$HelpDialog.hide()
		View.SelectDifficulty:
			$Main.hide()
			$SelectMission.hide()
			$SelectPlayer.hide()
			$SelectDifficulty.show()
			$HelpDialog.hide()
			$SelectDifficulty/Return.grab_focus()
		View.Controls:
			$Main.hide()
			$SelectMission.hide()
			$SelectPlayer.hide()
			$SelectDifficulty.hide()
			$HelpDialog.activate()

#endregion
