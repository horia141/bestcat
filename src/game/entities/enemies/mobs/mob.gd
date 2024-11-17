class_name Mob
extends Enemy

const SleepSignScn = preload("res://entities/enemies/sleep-sign/sleep-sign.tscn")

var sleep_sign = null

#region Construction

func post_ready_prepare(enemy_desc: Application.EnemyDesc, player: Game.PlayerProxy, init_position: Vector2, difficulty: Application.MissionDifficulty) -> void:
	super.post_ready_prepare(enemy_desc, player, init_position, difficulty)
	
	sleep_sign = SleepSignScn.instantiate()
	sleep_sign.scale = sleep_sign.scale / self.scale
	sleep_sign.position = Vector2($Collision.shape.get_rect().position + Vector2($Collision.shape.get_rect().size.x, 0))
	
	var immediate_activation = true
	for child in get_children():
		if child is EnemyActivationArea:
			child.player_entered.connect(_player_entered_activation_area)
			child.player_exited.connect(_player_exited_activation_area)
			immediate_activation = false
			break
			
	var initial_color = Color.WHITE if immediate_activation else Color.GRAY
			
	add_child(sleep_sign)
	$Sprite.pause()
	init_tween.chain().tween_property(self, "modulate", initial_color, 0.2)
		
	if immediate_activation:
		_player_entered_activation_area(null)

#endregion

#region Game logic

func _player_entered_activation_area(player: Player) -> void:
	if state == EnemyState.Hidden or state == EnemyState.Dead:
		return
	state = EnemyState.Active
	$ShootTimer.wait_time = 0.1
	$ShootTimer.start()
	$Sprite.play("idle")
	
	var activation_tween = create_tween()
	activation_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	if is_ancestor_of(sleep_sign):
		remove_child(sleep_sign)
	
func _player_exited_activation_area(player: Player) -> void:
	if state == EnemyState.Hidden or state == EnemyState.Dead:
		return
	state = EnemyState.Inactive
	
	add_child(sleep_sign)
	$Sprite.pause()
	var activation_tween = create_tween()
	activation_tween.tween_property(self, "modulate", Color.GRAY, 0.2)
	
func destroy() -> void:
	super.destroy()
	if is_ancestor_of(sleep_sign):
		remove_child(sleep_sign)
	$ShootTimer.stop()
	$Sprite.play("explosion")
	$Collision.set_deferred("disabled", true)
	set_deferred("freeze", true)
	await $Sprite.animation_finished
	destroyed.emit()
	
func is_bound_to_dark_tower() -> bool:
	return true

#endregion
