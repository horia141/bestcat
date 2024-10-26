class_name HealthBar
extends Node2D

@export var max_life: int = 10
var _life: int = 5
@export var life: int:
	get:
		return _life
	set(value):
		_life = value
		if has_node("TextureProgressBar"):
			$TextureProgressBar.value = float(value) / max_life * $TextureProgressBar.max_value
