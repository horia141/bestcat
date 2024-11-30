class_name HumanMadeMission
extends Mission

#region Construction

func post_ready_prepare(mission_desc: Application.MissionDesc) -> void:
	super.post_ready_prepare(mission_desc)
	_compute_terain_map()
	await get_tree().create_timer(0.01).timeout
	init_completed.emit()
	
#endregion
