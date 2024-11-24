class_name MainMenuConfigureGenerate
extends VBoxContainer

signal got_configured_mission(mission_desc: Application.MissionDesc)
signal return_from()

var selected_map_size: Mission.MapSize = Mission.MapSize.Small
var selected_challenge: Mission.Challenge = Mission.Challenge.Forgiving

#region Game logic

func activate() -> void:
	show()
	$Controls/Margin/Layout/Continue.grab_focus()
	selected_map_size = Mission.MapSize.Small
	selected_challenge = Mission.Challenge.Forgiving
	_highlight()
	
func deactivate() -> void:
	hide()

func _select_small_map_size() -> void:
	selected_map_size = Mission.MapSize.Small
	_highlight()
	
func _select_medium_map_size() -> void:
	selected_map_size = Mission.MapSize.Medium
	_highlight()

func _select_large_map_size() -> void:
	selected_map_size = Mission.MapSize.Large
	_highlight()

func _select_forgiving_challenge() -> void:
	selected_challenge = Mission.Challenge.Forgiving
	_highlight()

func _select_punishing_challenge() -> void:
	selected_challenge = Mission.Challenge.Punishing
	_highlight()

func _select_deadly_challenge() -> void:
	selected_challenge = Mission.Challenge.Deadly
	_highlight()

func _continue_to() -> void:
	var new_mission_desc = Application.MissionDesc.new(
		Generated.Desc.title,
		Generated.Desc.ui_description,
		selected_map_size,
		selected_challenge,
		Generated.Desc.allowed_difficulties,
		Generated.Desc.scene
	)
	got_configured_mission.emit(new_mission_desc)

func _return_from() -> void:
	return_from.emit()
	
func _highlight() -> void:
	# Doing this by hand
	match selected_map_size:
		Mission.MapSize.Small:
			$Options/Margin/Layout/Size/Small.button_pressed = true
			$Options/Margin/Layout/Size/Medium.button_pressed = false
			$Options/Margin/Layout/Size/Large.button_pressed = false
		Mission.MapSize.Medium:
			$Options/Margin/Layout/Size/Small.button_pressed = false
			$Options/Margin/Layout/Size/Medium.button_pressed = true
			$Options/Margin/Layout/Size/Large.button_pressed = false
		Mission.MapSize.Large:
			$Options/Margin/Layout/Size/Small.button_pressed = false
			$Options/Margin/Layout/Size/Medium.button_pressed = false
			$Options/Margin/Layout/Size/Large.button_pressed = true			
			
	match selected_challenge:
		Mission.Challenge.Forgiving:
			$Options/Margin/Layout/Challenge/Forgiving.button_pressed = true
			$Options/Margin/Layout/Challenge/Punishing.button_pressed = false
			$Options/Margin/Layout/Challenge/Deadly.button_pressed = false
		Mission.Challenge.Punishing:
			$Options/Margin/Layout/Challenge/Forgiving.button_pressed = false
			$Options/Margin/Layout/Challenge/Punishing.button_pressed = true
			$Options/Margin/Layout/Challenge/Deadly.button_pressed = false
		Mission.Challenge.Deadly:
			$Options/Margin/Layout/Challenge/Forgiving.button_pressed = false
			$Options/Margin/Layout/Challenge/Punishing.button_pressed = false
			$Options/Margin/Layout/Challenge/Deadly.button_pressed = true


#endregion
