class_name Treasure
extends Area2D

signal picked_up (player: Player)
signal expired ()

static var expires_in = DifficultyValue.new(INF, 30, 20)

var expires: bool = false

#region Construction

func _ready() -> void:
	body_entered.connect(_treasure_picked_up)
	
func post_ready_prepare(init_position: Vector2, difficulty: Application.MissionDifficulty, expires: bool) -> void:
	position = init_position
	self.expires = expires
	
	modulate = Color.TRANSPARENT
	var tween = self.create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	if expires and expires_in.get_for(difficulty) != INF:
		await self.ready
		var expires_timer = await get_tree().create_timer(expires_in.get_for(difficulty))
		expires_timer.timeout.connect(self._on_expires)

#endregion

#region Game logic

func _treasure_picked_up(body: Node) -> void:
	if body.is_in_group("Players"):
		picked_up.emit(body as Player)
		set_deferred("freeze", true)
		
func _on_expires() -> void:
	$Sprite.play("explosion")
	$Collision.set_deferred("disabled", true)
	set_deferred("freeze", true)
	await $Sprite.animation_finished
	expired.emit()
		
func apply_effect_to_player(player: Player) -> String:
	return ""

#endregion
