class_name PlainOfKoh
extends Mission

static var Desc:
	get:
		return Application.MissionDesc.new(
			"Plain of Koh",
			[Application.MissionDifficulty.Novice, Application.MissionDifficulty.Apprentice, Application.MissionDifficulty.Expert],
			preload("res://missions/plain-of-koh/plain-of-koh.tscn")
		)
