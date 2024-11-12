class_name MainMenuSelectDifficulty
extends VBoxContainer

const GameButtonScn = preload("res://ui/game-ui/game-button.tscn")

signal difficulty_selected(difficulty: Application.MissionDifficultyDesc)
signal return_from()

var selected_difficulty: Application.MissionDifficultyDesc = null
var all_mission_difficulties_desc: Array[Application.MissionDifficultyDesc] = []

#region Construction

func _ready() -> void:
	pass
	
func post_ready_prepare(all_mission_difficulties_desc: Array[Application.MissionDifficultyDesc]) -> void:
	self.selected_difficulty = null
	self.all_mission_difficulties_desc = all_mission_difficulties_desc

	for mission_difficulty_desc in all_mission_difficulties_desc:
		var difficulty_button = GameButtonScn.instantiate()
		difficulty_button.label = mission_difficulty_desc.ui_name
		difficulty_button.font_size = 20
		difficulty_button.pressed.connect(func (): _select_difficulty(mission_difficulty_desc))
		difficulty_button.focus_entered.connect(func (): _select_difficulty(mission_difficulty_desc))
		difficulty_button.gui_input.connect(func (event): _continue_to_explicit(event, mission_difficulty_desc))
		$Selector/List/Margin/List.add_child(difficulty_button)

#endregion

#region Game logic

func activate(selected_mission: Application.MissionDesc) -> void:
	show()
	$Selector/List/Margin/List.get_child(0).grab_focus()
	for idx in range(0, len(all_mission_difficulties_desc)):
		$Selector/List/Margin/List.get_child(idx).visible = selected_mission.allows_difficulty(all_mission_difficulties_desc[idx].difficulty)

func deactivate() -> void:
	hide()

func _select_difficulty(difficulty: Application.MissionDifficultyDesc) -> void:
	selected_difficulty = difficulty
	$Selector/Difficulty/Margin/Label.text = difficulty.ui_description
	$Controls/Margin/Layout/Continue.label = "Continue with %s" % difficulty.ui_name
	
func _continue_to_explicit(event: InputEvent, difficulty: Application.MissionDifficultyDesc) -> void:
	if not event.is_action_released("ui_accept"):
		return
	difficulty_selected.emit(difficulty)
	
func _return_from() -> void:
	return_from.emit()
	
func _continue_to() -> void:
	difficulty_selected.emit(selected_difficulty)

#endregion
