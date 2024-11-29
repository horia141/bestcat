class_name MainMenuSelectPlayerWeapon
extends VBoxContainer

signal player_weapon_selected(weapon: Application.PlayerWeaponDesc)
signal return_from()

const GameButtonScn = preload("res://ui/game-ui/game-button.tscn")

var selected_player_weapon: Application.PlayerWeaponDesc = null
var all_player_weapons: Array[PlayerWeapon] = []
var all_player_weapons_desc: Array[Application.PlayerWeaponDesc] = []

func _ready() -> void:
	pass
	
func post_ready_prepare(all_player_weapons_desc: Array[Application.PlayerWeaponDesc]) -> void:	
	selected_player_weapon = null
	all_player_weapons = []
	self.all_player_weapons_desc = all_player_weapons_desc
	
	var vp_x = $Selector/PlayerWeaponDetails/View/Margin/View/SubViewport.size.x
	var vp_y = $Selector/PlayerWeaponDetails/View/Margin/View/SubViewport.size.y
	
	for player_weapon_desc in all_player_weapons_desc:
		var player_weapon = player_weapon_desc.scene.instantiate() as PlayerWeapon
		var init_position = Vector2(vp_x / 2, vp_y / 2)
		var scale = min(vp_x / player_weapon.get_rect().size.x * 0.75, vp_y / player_weapon.get_rect().size.y * 0.75)
		player_weapon.position = init_position
		player_weapon.scale.x = scale
		player_weapon.scale.y = scale
		player_weapon.hide()
		$Selector/PlayerWeaponDetails/View/Margin/View/SubViewport.add_child(player_weapon)
		all_player_weapons.append(player_weapon)
		
		var player_weapon_button = GameButtonScn.instantiate()
		player_weapon_button.max_width = true
		player_weapon_button.label = player_weapon_desc.ui_name
		player_weapon_button.font_size = 20
		player_weapon_button.button_up.connect(func (): _select_player_weapon(player_weapon, player_weapon_desc))
		player_weapon_button.focus_entered.connect(func (): _select_player_weapon(player_weapon, player_weapon_desc))
		player_weapon_button.gui_input.connect(func (event): _continue_to_explicit(event, player_weapon, player_weapon_desc))
		$Selector/List/Margin/Layout.add_child(player_weapon_button)
		
#endregion

#region Game logic

func activate() -> void:
	show()
	_select_player_weapon(all_player_weapons[0], all_player_weapons_desc[0])
	$Selector/List/Margin/Layout.get_child(0).grab_focus()
	
func deactivate() -> void:
	hide()

func _select_player_weapon(player_weapon: PlayerWeapon, player_weapon_desc: Application.PlayerWeaponDesc) -> void:
	for other_player_weapon in all_player_weapons:
		other_player_weapon.hide()
	player_weapon.show()
	selected_player_weapon = player_weapon_desc
	$Selector/PlayerWeaponDetails/Stats/Margin/Layout/Description.text = player_weapon_desc.ui_description
	$Selector/PlayerWeaponDetails/Stats/Margin/Layout/Description.scroll_to_line(0)
	$Selector/PlayerWeaponDetails/Stats/Margin/Layout/Stats/MaxAmmo/Value.text = str(player_weapon_desc.max_ammo)
	$Selector/PlayerWeaponDetails/Stats/Margin/Layout/Stats/Damage/Value.text = str(player_weapon_desc.damage)
	$Selector/PlayerWeaponDetails/Stats/Margin/Layout/Stats/Range/Value.text = str(player_weapon_desc.range)
	$Selector/PlayerWeaponDetails/Stats/Margin/Layout/Stats/Speed/Value.text = str(player_weapon_desc.speed)
	$Selector/PlayerWeaponDetails/Stats/Margin/Layout/Stats/Accuracy/Value.text = str(player_weapon_desc.accuracy)
	$Selector/PlayerWeaponDetails/Stats/Margin/Layout/Stats/ReloadSpeed/Value.text = str(player_weapon_desc.reload_speed)
	$Controls/Margin/Layout/Continue.label = "Continue with %s" % player_weapon_desc.ui_name
	
func _continue_to_explicit(event: InputEvent, player_weapon: PlayerWeapon, player_weapon_desc: Application.PlayerWeaponDesc) -> void:
	if not event.is_action_released("ui_accept"):
		return
	player_weapon_selected.emit(player_weapon_desc)
	
func _return_from() -> void:
	return_from.emit()
	
func _continue_to() -> void:
	player_weapon_selected.emit(selected_player_weapon)

#endregion
