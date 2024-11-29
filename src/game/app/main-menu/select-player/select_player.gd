class_name MainMenuSelectPlayer
extends VBoxContainer

signal player_selected(player: Application.PlayerDesc)
signal return_from()

const GameButtonScn = preload("res://ui/game-ui/game-button.tscn")

var selected_player: Application.PlayerDesc = null
var all_players: Array[Player] = []
var all_players_desc: Array[Application.PlayerDesc] = []

#region Constructor

func _ready() -> void:
	pass
	
func post_ready_prepare(all_players_desc: Array[Application.PlayerDesc]) -> void:	
	selected_player = null
	all_players = []
	self.all_players_desc = all_players_desc
	
	var vp_x = $Selector/PlayerDetails/View/Margin/View/SubViewport.size.x
	var vp_y = $Selector/PlayerDetails/View/Margin/View/SubViewport.size.y
	
	for player_desc in all_players_desc:
		var player = player_desc.scene.instantiate() as Player
		var init_position = Vector2(vp_x / 2, vp_y / 2)
		var scale = min(vp_x / player.size_px.x * 0.75, vp_y / player.size_px.y * 0.75)
		player.post_ready_prepare(
			Application.PlayerInMission.new(player_desc, MagicWand.Desc), 
			Application.ConceptMode.InMainMenu, init_position, Application.MissionDifficulty.Apprentice)
		player.scale.x = scale
		player.scale.y = scale
		player.hide()
		$Selector/PlayerDetails/View/Margin/View/SubViewport.add_child(player)
		all_players.append(player)
		
		var player_button = GameButtonScn.instantiate()
		player_button.max_width = true
		player_button.label = player_desc.ui_name
		player_button.font_size = 20
		player_button.button_up.connect(func (): _select_player(player, player_desc))
		player_button.focus_entered.connect(func (): _select_player(player, player_desc))
		player_button.gui_input.connect(func (event): _continue_to_explicit(event, player, player_desc))
		$Selector/List/Margin/Layout.add_child(player_button)
		
#endregion

#region Game logic

func activate() -> void:
	show()
	_select_player(all_players[0], all_players_desc[0])
	$Selector/List/Margin/Layout.get_child(0).grab_focus()
	
func deactivate() -> void:
	hide()

func _select_player(player: Player, player_desc: Application.PlayerDesc) -> void:
	for other_player in all_players:
		other_player.hide()
	player.show()
	selected_player = player_desc
	$Selector/PlayerDetails/Stats/Margin/Layout/Description.text = player_desc.ui_description
	$Selector/PlayerDetails/Stats/Margin/Layout/Description.scroll_to_line(0)
	$Selector/PlayerDetails/Stats/Margin/Layout/Stats/Life/Value.text = str(player_desc.max_life)
	$Selector/PlayerDetails/Stats/Margin/Layout/Stats/Speed/Value.text = str(player_desc.max_speed)
	$Selector/PlayerDetails/Stats/Margin/Layout/Stats/ProjectilesCnt/Value.text = str(player_desc.max_projectiles_cnt)
	$Controls/Margin/Layout/Continue.label = "Continue with %s" % player_desc.ui_name
	
func _continue_to_explicit(event: InputEvent, player: Player, player_desc: Application.PlayerDesc) -> void:
	if not event.is_action_released("ui_accept"):
		return
	player_selected.emit(player_desc)
	
func _return_from() -> void:
	return_from.emit()
	
func _continue_to() -> void:
	player_selected.emit(selected_player)

#endregion
