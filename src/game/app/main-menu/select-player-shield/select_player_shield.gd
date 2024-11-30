class_name MainMenuSelectPlayerShield
extends VBoxContainer


signal player_shield_selected(shield: Application.PlayerShieldDesc)
signal return_from()

const GameButtonScn = preload("res://ui/game-ui/game-button.tscn")

var selected_player_shield: Application.PlayerShieldDesc = null
var all_player_shields: Array[PlayerShield] = []
var all_player_shields_desc: Array[Application.PlayerShieldDesc] = []

func _ready() -> void:
	pass
	
func post_ready_prepare(all_player_shields_desc: Array[Application.PlayerShieldDesc]) -> void:	
	selected_player_shield = null
	all_player_shields = []
	self.all_player_shields_desc = all_player_shields_desc
	
	var vp_x = $Selector/PlayerShieldDetails/View/Margin/View/SubViewport.size.x
	var vp_y = $Selector/PlayerShieldDetails/View/Margin/View/SubViewport.size.y
	
	for player_shield_desc in all_player_shields_desc:
		var player_shield = player_shield_desc.scene.instantiate() as PlayerShield
		var init_position = Vector2(vp_x / 2, vp_y / 2)
		var scale = min(vp_x / player_shield.get_rect().size.x * 0.75, vp_y / player_shield.get_rect().size.y * 0.75)
		player_shield.position = init_position
		player_shield.scale.x = scale
		player_shield.scale.y = scale
		player_shield.hide()
		$Selector/PlayerShieldDetails/View/Margin/View/SubViewport.add_child(player_shield)
		all_player_shields.append(player_shield)
		
		var player_shield_button = GameButtonScn.instantiate()
		player_shield_button.max_width = true
		player_shield_button.label = player_shield_desc.ui_name
		player_shield_button.font_size = 20
		player_shield_button.button_up.connect(func (): _select_player_shield(player_shield, player_shield_desc))
		player_shield_button.focus_entered.connect(func (): _select_player_shield(player_shield, player_shield_desc))
		player_shield_button.gui_input.connect(func (event): _continue_to_explicit(event, player_shield, player_shield_desc))
		$Selector/List/Margin/Layout.add_child(player_shield_button)
		
#endregion

#region Game logic

func activate() -> void:
	show()
	_select_player_shield(all_player_shields[0], all_player_shields_desc[0])
	$Selector/List/Margin/Layout.get_child(0).grab_focus()
	
func deactivate() -> void:
	hide()

func _select_player_shield(player_shield: PlayerShield, player_shield_desc: Application.PlayerShieldDesc) -> void:
	for other_player_shield in all_player_shields:
		other_player_shield.hide()
	player_shield.show()
	selected_player_shield = player_shield_desc
	$Selector/PlayerShieldDetails/Stats/Margin/Layout/Description.text = player_shield_desc.ui_description
	$Selector/PlayerShieldDetails/Stats/Margin/Layout/Description.scroll_to_line(0)
	$Selector/PlayerShieldDetails/Stats/Margin/Layout/Stats/MaxDefencesCnt/Value.text = str(player_shield_desc.max_defends_cnt)
	$Selector/PlayerShieldDetails/Stats/Margin/Layout/Stats/Reload/Value.text = str(player_shield_desc.reload_duration)
	$Controls/Margin/Layout/Continue.label = "Continue with %s" % player_shield_desc.ui_name
	
func _continue_to_explicit(event: InputEvent, player_shield: PlayerShield, player_shield_desc: Application.PlayerShieldDesc) -> void:
	if not event.is_action_released("ui_accept"):
		return
	player_shield_selected.emit(player_shield_desc)
	
func _return_from() -> void:
	return_from.emit()
	
func _continue_to() -> void:
	player_shield_selected.emit(selected_player_shield)

#endregion
