class_name Tutorial
extends Mission

static var Desc:
	get:
		return Application.MissionDesc.new(
			"Tutorial",
			"Learn how to play the game",
			Mission.MapSize.Custom,
			[Application.MissionDifficulty.Novice],
			preload("res://missions/tutorial/tutorial.tscn")
		)
