class_name RubyStaff
extends PlayerWeapon

static var Desc:
	get:
		return Application.PlayerWeaponDesc.new(
			"Ruby Staff",
			"""
				A common staff used by all manner of wizards and mages.
				
				Can hold a good charge and send projectiles far, but accuracy and reload leave much to be desired.
			""",
			preload("res://entities/players/weapons/ruby-staff/ruby-staff.tscn"),
			6,
			1,
			300,
			700,
			6,
			10
		)
