class_name PlainOfKoh
extends HumanMadeMission

static var Desc:
	get:
		return Application.MissionDesc.new(
			"Plain of Koh",
			"""
				The plain of Koh was a once beautiful land ruled by a noble family.

				An army of evil monsters has invaded and laid waste to the land!
				
				It's up to you to push them out and restore order to the land of Koh!
			""",
			Mission.GenerationMethod.HumanMade,
			Mission.MapSize.Custom,
			Mission.Challenge.Punishing,
			[Application.MissionDifficulty.Novice, Application.MissionDifficulty.Apprentice, Application.MissionDifficulty.Expert],
			preload("res://missions/plain-of-koh/plain-of-koh.tscn")
		)
