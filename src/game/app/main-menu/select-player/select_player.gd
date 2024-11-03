class_name MainMenuSelectPlayer
extends VBoxContainer

signal player_selected(player: Application.PlayerDesc)
signal return_from()

var selected_player: Application.PlayerDesc = null
var all_players: Array[Player] = []
var all_players_desc: Array[Application.PlayerDesc] = []

#region Constructor

func _ready() -> void:
	selected_player = null
	all_players = []
	
func post_ready_prepare(all_players_desc: Array[Application.PlayerDesc]) -> void:	
	selected_player = null
	all_players = []
	self.all_players_desc = all_players_desc
	
	var vp_x = $Selector/SubViewportContainer/SubViewport.size.x
	var vp_y = $Selector/SubViewportContainer/SubViewport.size.y
	
	for player_desc in all_players_desc:
		var player = player_desc.scene.instantiate() as Player
		var init_position = Vector2(vp_x / 2, vp_y / 2)
		var scale = min(vp_x / player.size_px.x * 0.75, vp_y / player.size_px.y * 0.75)
		player.post_ready_prepare(Entity.Mode.InMainMenu, init_position, Application.MissionDifficulty.Apprentice)
		player.scale.x = scale
		player.scale.y = scale
		player.hide()
		$Selector/SubViewportContainer/SubViewport.add_child(player)
		all_players.append(player)
		
		var player_button = Button.new()
		player_button.text = player.ui_name
		player_button.button_up.connect(func (): _select_player(player, player_desc))
		player_button.focus_entered.connect(func (): _select_player(player, player_desc))
		player_button.gui_input.connect(func (event): _continue_to_explicit(event, player, player_desc))
		player_button.add_theme_font_size_override("font_size", 36)
		$Selector/List.add_child(player_button)
		
#endregion

#region Game logic

func activate() -> void:
	show()
	_select_player(all_players[0], all_players_desc[0])
	$Selector/List.get_child(0).grab_focus()

func _select_player(player: Player, player_desc: Application.PlayerDesc) -> void:
	for other_player in all_players:
		other_player.hide()
	player.show()
	selected_player = player_desc
	$Controls/Continue.text = "Continue with %s" % player.ui_name
	
func _continue_to_explicit(event: InputEvent, player: Player, player_desc: Application.PlayerDesc) -> void:
	if not event.is_action_released("ui_accept"):
		return
	player_selected.emit(player_desc)
	
func _return_from() -> void:
	return_from.emit()
	
func _continue_to() -> void:
	player_selected.emit(selected_player)

#endregion
