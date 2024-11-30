class_name SapphireStaff
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Sapphire Staff",
			"""
				This staff is for mages that like to get in the thick of it.
				
				It has great energy, but trades off range and accuracy for it.
			""",
			preload("res://entities/players/weapons/sapphire-staff/sapphire-staff.tscn"),
			10,
			1,
			200,
			400,
			6,
			10
		)
