class_name DarkTower
extends Structure

const MAX_LIFE = 3

var life = MAX_LIFE
var operational = true

#region Constructor

#endregion

#region Game logic

func on_hit_by_player_projectile() -> void:
	if not operational:
		return
		
	life = life - 1
	
	if life == 0:
		operational = false
		
		$Explosion.visible = true
		$Explosion.play("explosion")
		
		$BaseSprite.play("destroyed")
		await $Explosion.animation_finished
		await $BaseSprite.animation_finished

#endregion
