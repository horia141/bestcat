class_name MagicWand
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Magic Wand",
			"Description",
			preload("res://entities/players/weapons/magic-want/magic-wand.tscn"),
			3,
			1,
			200,
			1000,
			10,
			5
		)
