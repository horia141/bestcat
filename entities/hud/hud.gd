class_name HUD
extends CanvasLayer

#region Game logic

func update_player(best_cat: BestCat) -> void:
	$PlayerInfo/Life/LifeCntText.text = str(best_cat.life)
	$PlayerInfo/ProjectilesCnt/ProjectilesCntText.text = str(best_cat.projectiles_cnt)
	if best_cat.projectiles_cnt_regen_factor > 0:
		$PlayerInfo/ProjectilesCnt/ProjectilesCntRegenFactorText.text = "." + str(best_cat.projectiles_cnt_regen_factor)
	else:
		$PlayerInfo/ProjectilesCnt/ProjectilesCntRegenFactorText.text = ""
		
func update_mission(dark_towers_left_cnt: int) -> void:
	$MissionInfo/DarkTowersLeftCntText.text = str(dark_towers_left_cnt)
	
#endregion
 
