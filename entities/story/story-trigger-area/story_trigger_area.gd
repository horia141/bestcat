class_name StoryTriggerArea
extends Area2D

signal player_entered ()

var triggered = false

#region Game logic

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	if triggered:
		return
		
	triggered = true
	player_entered.emit()

#endregion
