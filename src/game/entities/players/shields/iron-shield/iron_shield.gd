class_name IronShield
extends PlayerShield

static var Desc: Application.PlayerShieldDesc:
	get:
		return Application.PlayerShieldDesc.new(
			"Iron Shield",
			"""
				A sturdy shield that can take a beating, but is slow to recharge.
			""",
			preload("res://entities/players/shields/iron-shield/iron-shield.tscn"),
			4,
			20
		)
