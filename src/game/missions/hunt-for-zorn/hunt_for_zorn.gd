class_name HuntForZorn
extends Mission

static var Desc:
	get:
		return Application.MissionDesc.new(
			"Hunt for Zorn", 
			"""
				Welcome to the island of Zorn. Destroy the dark towers and beat Zorn the stone killer to claim success!
			""",
			Mission.MapSize.Small,
			Mission.Challenge.Forgiving,
			[Application.MissionDifficulty.Novice, Application.MissionDifficulty.Apprentice, Application.MissionDifficulty.Expert],
			preload("res://missions/hunt-for-zorn/hunt-for-zorn.tscn")
		)
