class_name EnemyActivationArea
extends Area2D

signal player_entered(player: Player)
signal player_exited(player: Player)

#region Game logic

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	player_entered.emit(body)


func _on_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
	player_exited.emit(body)

#endregion
