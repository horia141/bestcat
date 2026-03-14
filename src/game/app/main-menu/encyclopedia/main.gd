class_name EncyclopediaMain
extends VBoxContainer

signal select_section_players()
signal select_section_weapons()
signal select_section_shields()
signal select_section_enemies()
signal select_section_lore()
signal return_from()

#region Construction

#endregion

#region Game logic

func activate() -> void:
	show()
	$Controls/Margin/Return.grab_focus()
	
func deactivate() -> void:
	hide()
	
func _select_players() -> void:
	select_section_players.emit()
	
func _select_weapons() -> void:
	select_section_weapons.emit()
	
func _select_shields() -> void:
	select_section_shields.emit()

func _select_enemies() -> void:
	select_section_enemies.emit()
	
func _select_lore() -> void:
	select_section_lore.emit()
	
func _return_from() -> void:
	return_from.emit()

#endregion
