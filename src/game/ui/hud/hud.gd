class_name HUD
extends CanvasLayer

#region Construction

func _ready() -> void:
	update_mission(Game.MissionState.GetReady, 0, 0, 0)

#endregion

#region Game logic

func update_player(player: Player) -> void:
	$PlayerInfo/Life/Text.text = str(player.life)
	$PlayerInfo/Speed/Text.text = str(player.speed)
	if player.speed_regen_factor > 0:
		$PlayerInfo/Speed/Regen/Factor.value = player.speed_regen_factor / player.SPEED_REGEN_CUTOFF.get_for(player.difficulty) * 100
	else:
		$PlayerInfo/Speed/Regen/Factor.value = 0
	$PlayerInfo/ProjectilesCnt/Text.text = str(player.projectiles_cnt)
	if player.projectiles_cnt_regen_factor > 0:
		$PlayerInfo/ProjectilesCnt/Regen/Factor.value = player.projectiles_cnt_regen_factor / player.PROJECTILES_CNT_REGEN_CUTOFF.get_for(player.difficulty) * 100
	else:
		$PlayerInfo/ProjectilesCnt/Regen/Factor.value = 0
		
func update_mission(mission_state: Game.MissionState, dark_towers_left_cnt: int, bosses_left_cnt: int, score: int) -> void:
	$DarkTowersLeftCnt/Text.text = str(dark_towers_left_cnt)
	$BossesLeftCnt/Text.text = str(bosses_left_cnt)
	$Score/Text.text = str(score)
	
	match mission_state:
		Game.MissionState.Start:
			$PlayerInfo.hide()
			$Score.hide()
			$DarkTowersLeftCnt.hide()
			$BossesLeftCnt.hide()
		Game.MissionState.GetReady:
			$PlayerInfo.show()
			$Score.hide()
			$DarkTowersLeftCnt.hide()
			$BossesLeftCnt.hide()
		Game.MissionState.DestroyDarkTowers:
			$PlayerInfo.show()
			$Score.show()
			$DarkTowersLeftCnt.show()
			$BossesLeftCnt.hide()
		Game.MissionState.BossFight:
			$PlayerInfo.show()
			$Score.show()
			$DarkTowersLeftCnt.hide()
			$BossesLeftCnt.show()

#endregion
