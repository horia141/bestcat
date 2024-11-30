class_name ShieldBreaker
extends EnemyProjectile

#region Game logic

func apply_effect_to_player(player: Player) -> void:
	player.defends_cnt = player.defends_cnt - 1

#endregion
