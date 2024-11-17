class_name Macky
extends Player

static var Desc:
	get:
		return Application.PlayerDesc.new(
			"Macky",
			"""
				Macky was bought by Kenny when he started farming.
				
				Macky is a bit tougher, but can't do as much damage.
			""",
			preload("res://entities/players/macky/macky.tscn"),
			6,
			5,
			4
		)
