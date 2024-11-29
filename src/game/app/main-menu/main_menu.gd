class_name MainMenu
extends CanvasLayer

signal new_game (mission_attempt: Application.MissionAttempt)
signal quit_game ()

enum View {
	Main,
	SelectMission,
	SelectPlayer,
	SelectPlayerWeapon,
	SelectDifficulty,
	Controls
}

var view = View.Main

var selected_player: Application.PlayerDesc = null
var selected_player_weapon: Application.PlayerWeaponDesc = null
var selected_mission: Application.MissionDesc = null
var selected_difficulty: Application.MissionDifficultyDesc = null
var all_mobs_desc: Array[Application.EnemyDesc] = []
var all_bosses_desc: Array[Application.EnemyDesc] = []

#region Construction

func _ready() -> void:
	_show()
	
func post_ready_process(
		all_players_desc: Array[Application.PlayerDesc],
		all_player_weapons_desc: Array[Application.PlayerWeaponDesc],
		all_missions_desc: Array[Application.MissionDesc],
		all_mission_difficulties_desc: Array[Application.MissionDifficultyDesc],
		all_mobs_desc: Array[Application.EnemyDesc],
		all_bosses_desc: Array[Application.EnemyDesc]) -> void:
	$SelectMission.post_ready_prepare(all_missions_desc)
	$SelectPlayer.post_ready_prepare(all_players_desc)
	$SelectPlayerWeapon.post_ready_prepare(all_player_weapons_desc)
	$SelectDifficulty.post_ready_prepare(all_mission_difficulties_desc)
	self.all_mobs_desc = all_mobs_desc
	self.all_bosses_desc = all_bosses_desc
	
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
	
func _select_player_go_to_select_player_weapon(player_desc: Application.PlayerDesc) -> void:
	selected_player = player_desc
	view = View.SelectPlayerWeapon
	_show()
	
func _select_player_go_to_select_mission() -> void:
	view = View.SelectMission
	_show()

func _select_player_weapon_go_to_select_difficulty(player_weapon_desc: Application.PlayerWeaponDesc) -> void:
	selected_player_weapon = player_weapon_desc
	view = View.SelectDifficulty	
	_show()
	
func _select_player_weapon_go_to_select_player() -> void:
	view = View.SelectPlayer
	_show()
	
func _select_difficulty_go_to_new_game(difficulty: Application.MissionDifficultyDesc) -> void:
	var player_in_mission = Application.PlayerInMission.new(
		selected_player,
		selected_player_weapon,
	)
	var mission_attempt = Application.MissionAttempt.new(
		player_in_mission, selected_mission, difficulty, all_mobs_desc, all_bosses_desc)
	new_game.emit(mission_attempt)
	view = View.Main
	_show()
	
func _select_difficulty_go_to_select_player_weapon() -> void:
	view = View.SelectPlayerWeapon
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
			$SelectMission.deactivate()
			$SelectPlayer.deactivate()
			$SelectPlayerWeapon.deactivate()
			$SelectDifficulty.deactivate()
			$ShowControls.deactivate()
			$Main/Commands/Margin/Layout/NewGame.grab_focus()
		View.SelectMission:
			$Main.hide()
			$SelectMission.activate()
			$SelectPlayer.deactivate()
			$SelectPlayerWeapon.deactivate()
			$SelectDifficulty.deactivate()
			$ShowControls.deactivate()
		View.SelectPlayer:
			$Main.hide()
			$SelectMission.deactivate()
			$SelectPlayer.activate()
			$SelectPlayerWeapon.deactivate()
			$SelectDifficulty.deactivate()
			$ShowControls.deactivate()
		View.SelectPlayerWeapon:
			$Main.hide()
			$SelectMission.deactivate()
			$SelectPlayer.deactivate()
			$SelectPlayerWeapon.activate()
			$SelectDifficulty.deactivate()
			$ShowControls.deactivate()
		View.SelectDifficulty:
			$Main.hide()
			$SelectMission.deactivate()
			$SelectPlayer.deactivate()
			$SelectPlayerWeapon.deactivate()
			$SelectDifficulty.activate(selected_mission)
			$ShowControls.deactivate()
		View.Controls:
			$Main.hide()
			$SelectMission.deactivate()
			$SelectPlayer.deactivate()
			$SelectPlayerWeapon.deactivate()
			$SelectDifficulty.hide()
			$ShowControls.activate()
			
func _background_move() -> void:
	$Background/Path/Follow.progress += 5
	$Background/Image.position = $Background/Path/Follow.position

#endregion
