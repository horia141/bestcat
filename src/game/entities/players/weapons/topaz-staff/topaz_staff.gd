class_name TopazStaff
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Topaz Staff",
			"Description",
			preload("res://entities/players/weapons/topaz-staff/topaz-staff.tscn"),
			5,
			1,
			200,
			4,
			10,
			0.2
		)
