class_name Tutorial
extends Mission

static var Desc:
	get:
		return Application.MissionDesc.new(
			"Tutorial",
			[Application.MissionDifficulty.Novice],
			preload("res://missions/tutorial/tutorial.tscn")
		)
