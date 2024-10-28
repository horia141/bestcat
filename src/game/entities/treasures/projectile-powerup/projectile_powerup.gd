class_name ProjectilePowerUp
extends Treasure


#region Game logic

func apply_effect_to_player(player: Player) -> void:
	player.projectiles_cnt = player.projectiles_cnt + 1
	
#endregion
