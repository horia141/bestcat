class_name EmeraldWand
extends Weapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Emerald Staff",
			"Description",
			preload("res://entities/players/weapons/emerald-staff/emerald-wand.tscn"),
			5,
			1,
			200,
			4,
			10,
			0.2
		)
