class_name Portal
extends Structure

var _in_cooldown: bool = false

#region Construction

func _ready() -> void:
	_in_cooldown = false

#endregion

#region Game logic

var can_initiate_teleport: bool:
	get:
		return not _in_cooldown

var teleport_position: Vector2:
	get:
		return $TeleportPosition.global_position
		
func begin_cooldown() -> void:
	$CooldownTimer.start()
	_in_cooldown = true
	var gray_tween = create_tween()
	gray_tween.tween_property(self, "modulate", Color.GRAY, 0.2)
	gray_tween.tween_property($Vortex, "modulate", Color.TRANSPARENT, 0.2)
		

func _end_cooldown() -> void:
	_in_cooldown = false
	var gray_tween = create_tween()
	gray_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	gray_tween.tween_property($Vortex, "modulate", Color.WHITE, 0.2)

#endregion
