class_name LifePowerUp
extends Treasure

#region Game logic

func apply_effect_to_player(player: Player) -> String:
	player.life = player.life + 1
	return "Extra Life"
	
#endregion
