class_name MagicWand
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Magic Wand",
			"Description",
			preload("res://entities/players/weapons/magic-want/magic-wand.tscn"),
			5,
			1,
			200,
			4,
			10,
			0.2
		)
