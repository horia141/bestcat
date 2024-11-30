class_name PowerUpChest
extends Treasure

enum Effect {
	AddLife,
	AddSpeed,
	AddBullet,
	AddDefend,
	LoseLife,
	LoseSpeed,
	LoseBullet,
	LoseDefend
}

#region Game logic

static func _apply_effect(effect: Effect, player: Player) -> String:
	match effect:
		Effect.AddLife:
			player.life += 1
			return "extra Life"
		Effect.AddSpeed:
			player.speed += 1
			return "extra Speed"
		Effect.AddBullet:
			player.projectiles_cnt += 1
			return "extra Bullet"
		Effect.AddDefend:
			player.defends_cnt += 1
			return "extra Defend"
		Effect.LoseLife:
			player.life -= 1
			return "lost Life"
		Effect.LoseSpeed:
			player.speed -= 1
			return "lost Speed"
		Effect.LoseBullet:
			player.projectiles_cnt -= 1
			return "lost Bullet"
		Effect.LoseDefend:
			player.defends_cnt -= 1
			return "lost Defend"
	assert(1 != 0, "Unknown effect " % effect)
	return "Unknown"

func apply_effect_to_player(player: Player) -> String:
	var positive = randf_range(0, 1)
	if positive < 0.9:
		var effects = [Effect.AddLife, Effect.AddSpeed, Effect.AddBullet, Effect.AddDefend]
		effects.shuffle()
		var effects_cnt_choice = randf_range(0, 1)
		var descs = []
		if effects_cnt_choice < 0.75:
			descs.append(_apply_effect(effects[0], player))
		elif effects_cnt_choice < 0.9:
			descs.append(_apply_effect(effects[0], player))
			descs.append(_apply_effect(effects[1], player))
		elif effects_cnt_choice < 0.98:
			descs.append(_apply_effect(effects[0], player))
			descs.append(_apply_effect(effects[1], player))
			descs.append(_apply_effect(effects[2], player))
		else:
			descs.append(_apply_effect(effects[0], player))
			descs.append(_apply_effect(effects[1], player))
			descs.append(_apply_effect(effects[2], player))
			descs.append(_apply_effect(effects[3], player))
			
		return "You got " + ", ".join(descs)
	else:
		var effects = [Effect.LoseLife, Effect.LoseSpeed, Effect.LoseBullet, Effect.LoseDefend]
		effects.shuffle()
		var effects_cnt_choice = randf_range(0, 1)
		var descs = []
		if effects_cnt_choice < 0.75:
			descs.append(_apply_effect(effects[0], player))
		elif effects_cnt_choice < 0.9:
			descs.append(_apply_effect(effects[0], player))
			descs.append(_apply_effect(effects[1], player))
			pass
		elif effects_cnt_choice < 0.98:
			descs.append(_apply_effect(effects[0], player))
			descs.append(_apply_effect(effects[1], player))
			descs.append(_apply_effect(effects[2], player))
		else:
			descs.append(_apply_effect(effects[0], player))
			descs.append(_apply_effect(effects[1], player))
			descs.append(_apply_effect(effects[2], player))
			descs.append(_apply_effect(effects[3], player))
			
		return "You were afflicted by " + ", ".join(descs)
		

#endregion
