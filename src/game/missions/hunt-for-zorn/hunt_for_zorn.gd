class_name HuntForZorn
extends Mission

static var Desc:
	get:
		return Application.MissionDesc.new(
			"Hunt for Zorn", 
			[Application.MissionDifficulty.Novice, Application.MissionDifficulty.Apprentice, Application.MissionDifficulty.Expert],
			preload("res://missions/hunt-for-zorn/hunt-for-zorn.tscn")
		)
