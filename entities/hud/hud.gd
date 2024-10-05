class_name HUD
extends CanvasLayer

func update_life(new_life: int) -> void:
	$Life/LifeCnt.text = str(new_life)
