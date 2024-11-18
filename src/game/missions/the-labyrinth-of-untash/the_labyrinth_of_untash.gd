class_name TheLabyrinthOfUntash
extends Mission

static var Desc:
	get:
		return Application.MissionDesc.new(
			"The Labyrinth Of Untash",
			[Application.MissionDifficulty.Novice, Application.MissionDifficulty.Apprentice, Application.MissionDifficulty.Expert],
			preload("res://missions/the-labyrinth-of-untash/the-labyrinth-of-untash.tscn")
		)
