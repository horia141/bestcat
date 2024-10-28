class_name Tranquilizer
extends EnemyProjectile

#region Game logic

func apply_effect_to_player(player: Player) -> void:
	player.speed = max(0, player.speed - 1)

#endregion
