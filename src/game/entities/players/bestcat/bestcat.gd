class_name BestCat
extends Player

static var Desc:
	get:
		return Application.PlayerDesc.new(
			"BestCat",
			"""
				BestCat is the main character in the game and in some comics that will appear.
				
				He is an all around fighter.
			""",
			preload("res://entities/players/bestcat/bestcat.tscn"),
			6,
			6
		)
