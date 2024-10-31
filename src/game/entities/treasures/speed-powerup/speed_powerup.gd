class_name SpeedPowerUp
extends Treasure


#region Game logic

func apply_effect_to_player(player: Player) -> String:
	player.speed = player.speed + 1
	return "Extra Speed"
	
#endregion
