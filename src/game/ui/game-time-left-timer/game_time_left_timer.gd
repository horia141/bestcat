class_name GameTimeLeftTimer
extends CanvasLayer

signal game_time_expired ()

const WARNING_CUTOFF_SEC = 30
const WARNING_COLOR = Color.ORANGE
const DANGER_CUTOFF_SEC = 10
const DANGER_COLOR = Color.RED
static var INITIAL_GAME_TIME = DifficultyValue.new(180, 150, 120)

var game_time_left_sec = INITIAL_GAME_TIME.get_for(Application.MissionDifficulty.Apprentice)
var showing_warning_animation = false
var showing_danger_animation = false

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
	
	if game_time_left_sec <= WARNING_CUTOFF_SEC and not showing_warning_animation: 
		var tween = get_tree().create_tween()
		tween.bind_node($Text)
		tween.tween_property($Text, "modulate", WARNING_COLOR, 0.5)
		tween.chain().tween_property($Text, "modulate", Color.WHITE, 0.5)
		tween.set_loops(WARNING_CUTOFF_SEC - DANGER_CUTOFF_SEC)
		showing_warning_animation = true
	
	if game_time_left_sec <= 10 and not showing_danger_animation:
		var tween = get_tree().create_tween()
		tween.bind_node($Text)
		tween.tween_property($Text, "modulate", DANGER_COLOR, 0.5)
		tween.chain().tween_property($Text, "modulate", Color.WHITE, 0.5)
		tween.set_loops(DANGER_CUTOFF_SEC)
		showing_danger_animation = true
	
	if game_time_left_sec == 0:
		hide()
		$Timer.stop()
		game_time_expired.emit()
		
func __update_timer() -> void:
	var mins = game_time_left_sec / 60
	var secs = int(game_time_left_sec) % 60
	$Text.text = "%d:%02d" % [mins, secs]

#endregion
