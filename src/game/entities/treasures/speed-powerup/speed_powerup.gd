class_name SpeedPowerUp
extends Treasure


#region Game logic

func apply_effect_to_player(player: Player) -> void:
	player.speed = player.speed + 1
	
#endregion
