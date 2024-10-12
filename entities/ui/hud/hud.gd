class_name HUD
extends CanvasLayer

#region Construction

func _ready() -> void:
	update_mission(Game.MissionState.GetReady, 0, 0)

#endregion

#region Game logic

func update_player(best_cat: BestCat) -> void:
	$PlayerInfo/Life/LifeCntText.text = str(best_cat.life)
	$PlayerInfo/ProjectilesCnt/ProjectilesCntText.text = str(best_cat.projectiles_cnt)
	if best_cat.projectiles_cnt_regen_factor > 0:
		$PlayerInfo/ProjectilesCnt/ProjectilesCntRegenFactorText.text = "." + str(best_cat.projectiles_cnt_regen_factor)
	else:
		$PlayerInfo/ProjectilesCnt/ProjectilesCntRegenFactorText.text = ""
		
func update_mission(mission_state: Game.MissionState, dark_towers_left_cnt: int, bosses_left_cnt: int) -> void:
	$DarkTowersLeft/CntText.text = str(dark_towers_left_cnt)
	$BossesLeft/CntText.text = str(bosses_left_cnt)
	
	match mission_state:
		Game.MissionState.GetReady:
			$DarkTowersLeft.hide()
			$BossesLeft.hide()
		Game.MissionState.DestroyDarkTowers:
			$DarkTowersLeft.show()
			$BossesLeft.hide()
		Game.MissionState.BossFight:
			$DarkTowersLeft.hide()
			$BossesLeft.show()
	
#endregion
