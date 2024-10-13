class_name StartCountdown
extends CanvasLayer

signal done ()

@export var from: int = 3
var current: int = 3

#region Construction

func _ready() -> void:
	current = from
	$Counter.text = str(current)
	
	$Timer.wait_time = 1
	$Timer.start()

#endregion

#region Game logic

func _trigger() -> void:
	current = current - 1
	
	if current == 0:
		$Counter.text = "Start"
		await get_tree().create_timer(1).timeout
		done.emit()
	else:
		$Timer.wait_time = 1
		$Timer.start()
		$Counter.text = str(current)

#endregion
