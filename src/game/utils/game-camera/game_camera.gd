class_name GameCamera
extends Node2D

#region Construction

func _ready() -> void:
	pass
	
func post_ready_prepare(follow_path: RemoteTransform2D, world_size_in_px: Vector2) -> void:
	follow_path.remote_path = str(get_path())
	$TheCamera.limit_right = world_size_in_px.x
	$TheCamera.limit_bottom = world_size_in_px.y

#endregion
