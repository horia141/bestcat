class_name MagicWand
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Magic Wand",
			"""
				A versatile weapon for any mage. 
				
				Shoots quickly and accurately, but holds few projectiles and doesn't send them far or fast.
			""",
			preload("res://entities/players/weapons/magic-wand/magic-wand.tscn"),
			3,
			1,
			200,
			500,
			10,
			5
		)
