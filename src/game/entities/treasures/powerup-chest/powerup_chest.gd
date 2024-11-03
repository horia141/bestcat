class_name PowerUpChest
extends Treasure

#region Game logic

func apply_effect_to_player(player: Player) -> String:
	var positive = randf_range(0, 1)
	if positive < 0.9:
		var choice = randf_range(0, 1)
		if choice < 0.3:
			player.life = player.life + 1
			return "Extra Life"
		elif choice < 0.6:
			player.speed = player.speed + 1
			return "Extra Speed"
		elif choice < 0.9:
			player.projectiles_cnt = player.projectiles_cnt + 1
			return "Extra Bullet"
		elif choice < 0.93:
			player.life = player.life + 1
			player.speed = player.speed + 1
			return "Extra Life and Speed! What luck!"
		elif choice < 0.96:
			player.life = player.life + 1
			player.projectiles_cnt = player.projectiles_cnt + 1
			return "Extra Life and Bullet! What luck!"
		elif choice < 0.99:
			player.speed = player.speed + 1
			player.projectiles_cnt = player.projectiles_cnt + 1
			return "Extra Speed and Bullet! What luck!"
		else:
			player.life = player.life + 1
			player.speed = player.speed + 1
			player.projectiles_cnt = player.projectiles_cnt + 1
			return "Extra Life, Speed and Bullet! Unheard of!"
	else:
		var choice = randf_range(0, 1)
		if choice < 0.3:
			player.life = max(1, player.life - 1)
			return "Lost Life"
		elif choice < 0.6:
			player.speed = max(1, player.speed - 1)
			return "Lost Speed"
		elif choice < 0.9:
			player.projectiles_cnt = max(1, player.projectiles_cnt - 1)
			return "Lost Bullet"
		elif choice < 0.93:
			player.life = max(1, player.life - 1)
			player.speed = max(1, player.speed - 1)
			return "Lost Life and Speed! What misfortune!"
		elif choice < 0.96:
			player.life = max(1, player.life - 1)
			player.projectiles_cnt = max(1, player.projectiles_cnt - 1)
			return "Lost Life and Bullet! What misfortune!"
		elif choice < 0.99:
			player.speed = max(1, player.speed - 1)
			player.projectiles_cnt = max(1, player.projectiles_cnt - 1)
			return "Lost Speed and Bullet! What misfortune!"
		else:
			player.life = max(1, player.life - 1)
			player.speed = max(1, player.speed - 1)
			player.projectiles_cnt = max(1, player.projectiles_cnt - 1)
			return "Lost Life, Speed and Bullet! Disatruous!"
		

#endregion
