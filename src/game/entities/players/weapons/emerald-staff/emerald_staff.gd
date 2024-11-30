class_name EmeraldStaff
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Emerald Staff",
			"""
				A rare staff preferred by the witches of the forests of mount Alpi.
				
				Shoots fast over a great distance, but has low charge.
			""",
			preload("res://entities/players/weapons/emerald-staff/emerald-staff.tscn"),
			3,
			1,
			500,
			1000,
			8,
			4
		)
