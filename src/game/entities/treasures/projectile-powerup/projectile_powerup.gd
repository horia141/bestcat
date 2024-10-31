class_name ProjectilePowerUp
extends Treasure


#region Game logic

func apply_effect_to_player(player: Player) -> String:
	player.projectiles_cnt = player.projectiles_cnt + 1
	return "Extra Bullet"
	
#endregion
