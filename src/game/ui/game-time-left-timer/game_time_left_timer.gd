class_name GameTimeLeftTimer
extends CanvasLayer

signal game_time_expired ()

static var INITIAL_GAME_TIME = DifficultyValue.new(180, 150, 120)

var game_time_left_sec = INITIAL_GAME_TIME.get_for(Application.MissionDifficulty.Apprentice)

#region Construction

func _ready() -> void:
	pass
	
func post_ready_prepare(difficulty: Application.MissionDifficulty) -> void:
	game_time_left_sec = INITIAL_GAME_TIME.get_for(difficulty)

#endregion

#region Game logic

func begin() -> void:
	show()
	$Timer.start()
	__update_timer()
	
func mark_dark_tower_destroyed() -> void:
	game_time_left_sec = game_time_left_sec + 15
	__update_timer()

func _on_timer_timeout() -> void:
	game_time_left_sec = game_time_left_sec - 1
	__update_timer()
	
	if game_time_left_sec == 0:
		$Timer.stop()
		game_time_expired.emit()
		
func __update_timer() -> void:
	var mins = game_time_left_sec / 60
	var secs = int(game_time_left_sec) % 60
	$Text.text = "%d:%02d" % [mins, secs]

#endregion
