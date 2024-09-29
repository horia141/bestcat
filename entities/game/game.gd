extends Node


func _ready() -> void:
	var levelSizeInCells = $Level/Terrain.get_used_rect().size
	var tileSizeInPx = $Level/Terrain.tile_set.tile_size
	var levelSizeInPx = levelSizeInCells * tileSizeInPx
	$BestCat/Camera2D.limit_right = levelSizeInPx.x
	$BestCat/Camera2D.limit_bottom = levelSizeInPx.y
