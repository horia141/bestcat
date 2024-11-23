class_name TheLabyrinthOfUntash
extends Mission

static var Desc:
	get:
		return Application.MissionDesc.new(
			"The Labyrinth Of Untash",
			"""
				The witch Untash has raised this island from the sea and shaped it like the labyrinth from the stories she loved as a child.

				She has also filled it with monsters and demons! And treasures without number!
				
				Defeat her and her minions to claim a great prize
			""",
			Mission.MapSize.Medium,
			[Application.MissionDifficulty.Novice, Application.MissionDifficulty.Apprentice, Application.MissionDifficulty.Expert],
			preload("res://missions/the-labyrinth-of-untash/the-labyrinth-of-untash.tscn")
		)
