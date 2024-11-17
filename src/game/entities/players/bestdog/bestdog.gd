class_name BestDog
extends Player

static var Desc:
	get:
		return Application.PlayerDesc.new(
			"BestDog",
			"""
				BestDog is BestCat's competitor for Kenny's affection (and food)!
				
				He's very fast, but low bite!
			""",
			preload("res://entities/players/bestdog/bestdog.tscn"),
			4,
			7,
			4
		)
