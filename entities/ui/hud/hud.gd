class_name HUD
extends CanvasLayer

#region Construction

func _ready() -> void:
	update_mission(Game.MissionState.GetReady, 0, 0, 0)

#endregion

#region Game logic

func update_player(best_cat: BestCat) -> void:
	$PlayerInfo/Life/Text.text = str(best_cat.life)
	$PlayerInfo/ProjectilesCnt/Text.text = str(best_cat.projectiles_cnt)
	if best_cat.projectiles_cnt_regen_factor > 0:
		$PlayerInfo/ProjectilesCnt/RegenFactorText.text = "." + str(best_cat.projectiles_cnt_regen_factor)
	else:
		$PlayerInfo/ProjectilesCnt/RegenFactorText.text = ""
		
func update_mission(mission_state: Game.MissionState, dark_towers_left_cnt: int, bosses_left_cnt: int, score: int) -> void:
	$DarkTowersLeftCnt/Text.text = str(dark_towers_left_cnt)
	$BossesLeftCnt/Text.text = str(bosses_left_cnt)
	$Score/Text.text = str(score)
	
	match mission_state:
		Game.MissionState.GetReady:
			$DarkTowersLeftCnt.hide()
			$BossesLeftCnt.hide()
		Game.MissionState.DestroyDarkTowers:
			$DarkTowersLeftCnt.show()
			$BossesLeftCnt.hide()
		Game.MissionState.BossFight:
			$DarkTowersLeftCnt.hide()
			$BossesLeftCnt.show()
	
#endregion
