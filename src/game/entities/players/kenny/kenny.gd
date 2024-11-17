class_name Kenny
extends Player

static var Desc:
	get:
		return Application.PlayerDesc.new(
			"Kenny",
			"""
				Kenny is BestCat's human.
				
				He's slower than the other players, but packs a punch.
			""",
			preload("res://entities/players/kenny/kenny.tscn"),
			5,
			3,
			7
		)
