class_name SapphireStaff
extends Weapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Sapphire Staff",
			"Description",
			preload("res://entities/players/weapons/sapphire-staff/sapphire-staff.tscn"),
			5,
			1,
			200,
			4,
			10,
			0.2
		)
