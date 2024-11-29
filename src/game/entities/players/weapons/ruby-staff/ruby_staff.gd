class_name RubyStaff
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Ruby Staff",
			"Description",
			preload("res://entities/players/weapons/ruby-staff/ruby-staff.tscn"),
			5,
			1,
			200,
			4,
			10,
			0.2
		)
