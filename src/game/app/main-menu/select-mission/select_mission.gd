class_name MainMenuSelectMission
extends VBoxContainer

signal mission_selected(mission: Application.MissionDesc)
signal return_from()

var selected_mission: Application.MissionDesc = null
var all_missions: Array[Mission] = []
var all_missions_desc: Array[Application.MissionDesc] = []

#region Constructor

func _ready() -> void:
	pass
	
func post_ready_prepare(all_missions_desc: Array[Application.MissionDesc]) -> void:	
	selected_mission = null
	all_missions = []
	self.all_missions_desc = all_missions_desc
	
	var vp_x = $Selector/SubViewportContainer/SubViewport.size.x
	var vp_y = $Selector/SubViewportContainer/SubViewport.size.y
	
	for mission_desc in all_missions_desc:
		var mission = mission_desc.scene.instantiate() as Mission
		var scale = min(vp_x / mission.size_in_px.x, vp_y / mission.size_in_px.y) * 0.75
		var init_position = Vector2((vp_x - mission.size_in_px.x * scale) / 2, (vp_y - mission.size_in_px.y * scale) / 2)
		mission.post_ready_prepare(Application.ConceptMode.InMainMenu)
		mission.position.x = init_position.x
		mission.position.y = init_position.y
		mission.scale.x = scale
		mission.scale.y = scale
		all_missions.append(mission)
		
		var mission_button = Button.new()
		mission_button.text = mission_desc.title
		mission_button.button_down.connect(func (): _select_mission(mission, mission_desc))
		mission_button.focus_entered.connect(func (): _select_mission(mission, mission_desc))
		mission_button.gui_input.connect(func (event): _continue_to_explicit(event, mission, mission_desc))
		mission_button.add_theme_font_size_override("font_size", 36)
		$Selector/List.add_child(mission_button)
		
#endregion

#region Game logic

func activate() -> void:
	show()
	$Selector/List.get_child(0).grab_focus()
	
func deactivate() -> void:
	hide()

func _select_mission(mission: Mission, mission_desc: Application.MissionDesc) -> void:
	if $Selector/SubViewportContainer/SubViewport.get_child_count() > 1:
		var last_mission = $Selector/SubViewportContainer/SubViewport.get_child(1)
		$Selector/SubViewportContainer/SubViewport.remove_child(last_mission)
	$Selector/SubViewportContainer/SubViewport.add_child(mission)
	selected_mission = mission_desc
	$Controls/Continue.text = "Continue with %s" % mission_desc.title
	
func _continue_to_explicit(event: InputEvent, mission: Mission, mission_desc: Application.MissionDesc) -> void:
	if not event.is_action_released("ui_accept"):
		return
	var last_mission = $Selector/SubViewportContainer/SubViewport.get_child(1)
	$Selector/SubViewportContainer/SubViewport.remove_child(last_mission)
	mission_selected.emit(mission_desc)
	
func _return_from() -> void:
	var last_mission = $Selector/SubViewportContainer/SubViewport.get_child(1)
	$Selector/SubViewportContainer/SubViewport.remove_child(last_mission)
	return_from.emit()
	
func _continue_to() -> void:
	var last_mission = $Selector/SubViewportContainer/SubViewport.get_child(1)
	$Selector/SubViewportContainer/SubViewport.remove_child(last_mission)
	mission_selected.emit(selected_mission)
	
#endregion
