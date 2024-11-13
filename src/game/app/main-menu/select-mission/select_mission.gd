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
		mission.post_ready_prepare(Application.ConceptMode.InMainMenu)
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

func _select_mission(mission: Mission, mission_desc: Application.MissionDesc) -> void:
	if $Selector/View/Margin/Layout/SubViewport.get_child_count() > 1:
		var last_mission = $Selector/View/Margin/Layout/SubViewport.get_child(1)
		$Selector/View/Margin/Layout/SubViewport.remove_child(last_mission)
		
	var vp_x = $Selector/View/Margin/Layout/SubViewport.size.x
	var vp_y = $Selector/View/Margin/Layout/SubViewport.size.y
		
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
		
	$Selector/View/Margin/Layout/SubViewport.add_child(map_node)		
	selected_mission = mission_desc
	$Controls/Margin/Layout/Continue.label = "Continue with %s" % mission_desc.title
	
func _continue_to_explicit(event: InputEvent, mission: Mission, mission_desc: Application.MissionDesc) -> void:
	if not event.is_action_released("ui_accept"):
		return
	var last_mission = $Selector/View/Margin/Layout/SubViewport.get_child(1)
	$Selector/View/Margin/Layout/SubViewport.remove_child(last_mission)
	mission_selected.emit(mission_desc)
	
func _return_from() -> void:
	var last_mission = $Selector/View/Margin/Layout/SubViewport.get_child(1)
	$Selector/View/Margin/Layout/SubViewport.remove_child(last_mission)
	return_from.emit()
	
func _continue_to() -> void:
	var last_mission = $Selector/View/Margin/Layout/SubViewport.get_child(1)
	$Selector/View/Margin/Layout/SubViewport.remove_child(last_mission)
	mission_selected.emit(selected_mission)
	
#endregion
