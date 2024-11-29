class_name SapphireStaff
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Sapphire Staff",
			"Description",
			preload("res://entities/players/weapons/sapphire-staff/sapphire-staff.tscn"),
			7,
			1,
			200,
			1000,
			10,
			7
		)
