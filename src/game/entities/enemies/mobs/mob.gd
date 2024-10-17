class_name Mob
extends Enemy

#region Construction

func post_ready_prepare(init_position: Vector2, difficulty: Application.MissionDifficulty) -> void:
	super.post_ready_prepare(init_position, difficulty)
	
	var immediate_activation = true
	for child in get_children():
		if child is EnemyActivationArea:
			child.player_entered.connect(_player_entered_activation_area)
			child.player_exited.connect(_player_exited_activation_area)
			immediate_activation = false
			return
			
	if immediate_activation:
		state = EnemyState.Active

#endregion

#region Game logic

func _player_entered_activation_area(player: Player) -> void:
	if state == EnemyState.Hidden or state == EnemyState.Dead:
		return
	state = EnemyState.Active
	$ShootTimer.wait_time = 0.1
	$ShootTimer.start()
	
func _player_exited_activation_area(player: Player) -> void:
	if state == EnemyState.Hidden or state == EnemyState.Dead:
		return
	state = EnemyState.Inactive

func on_hit_by_projectile() -> void:
	super.on_hit_by_projectile()
	if state == EnemyState.Hidden or state == EnemyState.Dead:
		return
	state = EnemyState.Dead
	$ShootTimer.stop()
	$AnimatedSprite2D.play("explosion")
	$Collision.set_deferred("disabled", true)
	set_deferred("freeze", true)
	await $AnimatedSprite2D.animation_finished
	destroyed.emit()

#endregion
