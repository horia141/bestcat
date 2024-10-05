class_name HUD
extends CanvasLayer

#region Game logic

func update(best_cat: BestCat) -> void:
	$Life/LifeCnt.text = str(best_cat.life)
	
#endregion
