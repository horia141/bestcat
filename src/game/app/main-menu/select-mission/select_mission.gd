class_name MainMenuSelectMission
extends VBoxContainer

signal mission_selected(mission: Application.MissionDesc)
signal return_from()

const GameButtonScn = preload("res://ui/game-ui/game-button.tscn")

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
	
	for mission_desc in all_missions_desc:
		var mission = mission_desc.scene.instantiate() as Mission
		mission.post_ready_prepare(mission_desc)
		all_missions.append(mission)
		
		var mission_button = GameButtonScn.instantiate()
		mission_button.label = mission_desc.title
		mission_button.font_size = 20
		mission_button.button_down.connect(func (): _select_mission(mission, mission_desc))
		mission_button.focus_entered.connect(func (): _select_mission(mission, mission_desc))
		mission_button.gui_input.connect(func (event): _continue_to_explicit(event, mission, mission_desc))
		$Selector/List/Margin/Layout.add_child(mission_button)
		
#endregion

#region Game logic

func activate() -> void:
	show()
	$Selector/List/Margin/Layout.get_child(0).grab_focus()
	
func deactivate() -> void:
	hide()
	
func _select_random_map() -> void:
	if $Selector/Details/View/Margin/Layout/SubViewport.get_child_count() > 1:
		var last_mission = $Selector/Details/View/Margin/Layout/SubViewport.get_child(1)
		$Selector/Details/View/Margin/Layout/SubViewport.remove_child(last_mission)
		
	var vp_x = $Selector/Details/View/Margin/Layout/SubViewport.size.x
	var vp_y = $Selector/Details/View/Margin/Layout/SubViewport.size.y	
		
	var desc_node = Label.new()
	desc_node.text = "?"
	desc_node.add_theme_font_size_override("font_size", 100)
	var font: Font = desc_node.get_theme_font("font")
	var size_in_px = font.get_multiline_string_size("?", 0, -1, 100)
	desc_node.position = Vector2((vp_x - size_in_px.x) / 2, (vp_y - size_in_px.y) / 2)
		
	$Selector/Details/View/Margin/Layout/SubViewport.add_child(desc_node)
	
	$Selector/Details/Stats/Margin/Layout/Description.text = "Chose a mission randomly from all the available ones"
	$Selector/Details/Stats/Margin/Layout/Stats/Size.text = "Unknown"
	
	selected_mission = all_missions_desc.pick_random()
	$Controls/Margin/Layout/Continue.label = "Continue with Random"
	
func _select_generated_map() -> void:
	if $Selector/Details/View/Margin/Layout/SubViewport.get_child_count() > 1:
		var last_mission = $Selector/Details/View/Margin/Layout/SubViewport.get_child(1)
		$Selector/Details/View/Margin/Layout/SubViewport.remove_child(last_mission)
		
	var vp_x = $Selector/Details/View/Margin/Layout/SubViewport.size.x
	var vp_y = $Selector/Details/View/Margin/Layout/SubViewport.size.y	
		
	var desc_node = Label.new()
	desc_node.text = "?"
	desc_node.add_theme_font_size_override("font_size", 100)
	var font: Font = desc_node.get_theme_font("font")
	var size_in_px = font.get_multiline_string_size("?", 0, -1, 100)
	desc_node.position = Vector2((vp_x - size_in_px.x) / 2, (vp_y - size_in_px.y) / 2)
		
	$Selector/Details/View/Margin/Layout/SubViewport.add_child(desc_node)
	
	$Selector/Details/Stats/Margin/Layout/Description.text = "Generate a map randomly"
	$Selector/Details/Stats/Margin/Layout/Stats/Size.text = "Unknown"
	
	selected_mission = Generated.Desc
	$Controls/Margin/Layout/Continue.label = "Continue with Generated"
	
func _select_mission(mission: Mission, mission_desc: Application.MissionDesc) -> void:
	if $Selector/Details/View/Margin/Layout/SubViewport.get_child_count() > 1:
		var last_mission = $Selector/Details/View/Margin/Layout/SubViewport.get_child(1)
		$Selector/Details/View/Margin/Layout/SubViewport.remove_child(last_mission)
		
	var vp_x = $Selector/Details/View/Margin/Layout/SubViewport.size.x
	var vp_y = $Selector/Details/View/Margin/Layout/SubViewport.size.y
		
	var terrain_map = mission.terrain_map
	
	var map_image = Image.create_empty(terrain_map.cols_cnt * 4, terrain_map.rows_cnt * 4, false, Image.Format.FORMAT_RGB8)
	
	for row_idx in range(0, terrain_map.rows_cnt):
		for col_idx in range(0, terrain_map.cols_cnt):
			var color = Color.GRAY
			match terrain_map.get_cell(row_idx, col_idx).type:
				Mission.TerrainType.Water:
					color = Color.CADET_BLUE
				Mission.TerrainType.Land:
					color = Color.SEA_GREEN
				Mission.TerrainType.LandObstacle:
					color = Color.SANDY_BROWN
				Mission.TerrainType.LandDecoration:
					color = Color.DIM_GRAY
			map_image.fill_rect(Rect2i(col_idx * 4, row_idx * 4, 4, 4), color)
	
	var map_texture = ImageTexture.create_from_image(map_image)
	var map_node = TextureRect.new()
	map_node.texture = map_texture
	var size_in_px = Vector2(terrain_map.cols_cnt * 4, terrain_map.rows_cnt * 4)
	var scale = min(vp_x / size_in_px.x, vp_y / size_in_px.y) * 0.75
	map_node.position = Vector2((vp_x - size_in_px.x * scale) / 2, (vp_y - size_in_px.y * scale) / 2)
	map_node.scale = Vector2(scale, scale)
		
	$Selector/Details/View/Margin/Layout/SubViewport.add_child(map_node)		
	
	$Selector/Details/Stats/Margin/Layout/Description.text = mission_desc.ui_description
	$Selector/Details/Stats/Margin/Layout/Description.scroll_to_line(0)
	$Selector/Details/Stats/Margin/Layout/Stats/Size.text = Mission.map_size_to_text(mission_desc.size)
	
	selected_mission = mission_desc
	$Controls/Margin/Layout/Continue.label = "Continue with %s" % mission_desc.title
	
func _continue_to_explicit_random(event: InputEvent) -> void:
	if not event.is_action_released("ui_accept"):
		return
	var last_mission = $Selector/Details/View/Margin/Layout/SubViewport.get_child(1)
	$Selector/Details/View/Margin/Layout/SubViewport.remove_child(last_mission)
	mission_selected.emit(Generated.Desc)
	
func _continue_to_explicit_generated(event: InputEvent) -> void:
	if not event.is_action_released("ui_accept"):
		return
	var last_mission = $Selector/Details/View/Margin/Layout/SubViewport.get_child(1)
	$Selector/Details/View/Margin/Layout/SubViewport.remove_child(last_mission)
	mission_selected.emit(all_missions_desc.pick_random())
	
func _continue_to_explicit(event: InputEvent, mission: Mission, mission_desc: Application.MissionDesc) -> void:
	if not event.is_action_released("ui_accept"):
		return
	var last_mission = $Selector/Details/View/Margin/Layout/SubViewport.get_child(1)
	$Selector/Details/View/Margin/Layout/SubViewport.remove_child(last_mission)
	mission_selected.emit(mission_desc)
	
func _return_from() -> void:
	var last_mission = $Selector/Details/View/Margin/Layout/SubViewport.get_child(1)
	$Selector/Details/View/Margin/Layout/SubViewport.remove_child(last_mission)
	return_from.emit()
	
func _continue_to() -> void:
	var last_mission = $Selector/Details/View/Margin/Layout/SubViewport.get_child(1)
	$Selector/Details/View/Margin/Layout/SubViewport.remove_child(last_mission)
	mission_selected.emit(selected_mission)
	
#endregion
