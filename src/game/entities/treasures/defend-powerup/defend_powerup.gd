class_name DefendPowerUp
extends Treasure

#region Game logic

func apply_effect_to_player(player: Player) -> String:
	player.defends_cnt = player.defends_cnt + 1
	return "Extra Defend"
	
#endregion
