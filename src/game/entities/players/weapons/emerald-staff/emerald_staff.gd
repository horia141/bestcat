class_name EmeraldStaff
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Emerald Staff",
			"Description",
			preload("res://entities/players/weapons/emerald-staff/emerald-staff.tscn"),
			5,
			1,
			200,
			1000,
			10,
			5
		)
