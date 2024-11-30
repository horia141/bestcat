class_name WoodenShield
extends PlayerShield

static var Desc: Application.PlayerShieldDesc:
	get:
		return Application.PlayerShieldDesc.new(
			"Wooden Shield",
			"""
				A light shield that's fast to recharge.
			""",
			preload("res://entities/players/shields/wooden-shield/wooden-shield.tscn"),
			2,
			5
		)
