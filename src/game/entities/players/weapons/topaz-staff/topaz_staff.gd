class_name TopazStaff
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Topaz Staff",
			"""
				The worlocks of Koh crafted this staff with range in mind.
				
				They sacrified accuracy and magic charge.
			""",
			preload("res://entities/players/weapons/topaz-staff/topaz-staff.tscn"),
			4,
			1,
			400,
			700,
			8,
			10
		)
