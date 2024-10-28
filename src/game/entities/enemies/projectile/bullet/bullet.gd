class_name Bullet
extends EnemyProjectile

#region Game logic

func apply_effect_to_player(player: Player) -> void:
	player.life = max(0, player.life - 1)

#endregion
