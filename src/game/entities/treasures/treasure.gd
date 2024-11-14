class_name Treasure
extends Area2D

signal picked_up (player: Player)

#region Construction

func _ready() -> void:
	body_entered.connect(_treasure_picked_up)
	
func post_ready_prepare(init_position: Vector2) -> void:
	position = init_position
	
	modulate = Color.TRANSPARENT
	var tween = self.create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

#endregion

#region Game logic

func _treasure_picked_up(body: Node) -> void:
	if body.is_in_group("Players"):
		picked_up.emit(body as Player)
		set_deferred("freeze", true)
		
func apply_effect_to_player(player: Player) -> String:
	return ""

#endregion
