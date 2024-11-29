class_name TopazStaff
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Topaz Staff",
			"Description",
			preload("res://entities/players/weapons/topaz-staff/topaz-staff.tscn"),
			10,
			1,
			200,
			1000,
			10,
			10
		)
