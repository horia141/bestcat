class_name RubyStaff
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Ruby Staff",
			"Description",
			preload("res://entities/players/weapons/ruby-staff/ruby-staff.tscn"),
			6,
			1,
			200,
			1000,
			10,
			6
		)
