class_name HUD
extends CanvasLayer

const EFFECTS_LOG_DISPLAY_SEC = 5

var effects_log: Array[String] = []
var effects_log_timer: Array[int] = []

#region Construction

func _ready() -> void:
	effects_log = []
	effects_log_timer = []
	update_mission(Game.MissionState.GetReady, 0, 0, 0)
	
func post_ready_prepare(player_in_mission: Application.PlayerInMission) -> void:
	var player = player_in_mission.player.scene.instantiate() as Player
	player.post_ready_prepare(player_in_mission, Application.ConceptMode.InHud, Vector2(16, 16), Application.MissionDifficulty.Novice)
	$PlayerInfo/Layout/Avatar/SubViewport.add_child(player)
	var weapon = player_in_mission.weapon.scene.instantiate() as PlayerWeapon
	weapon.post_ready_prepare(Application.ConceptMode.InHud)
	weapon.position = Vector2(16, 16)
	$PlayerInfo/Layout/Weapon/SubViewport.add_child(weapon)
	var shield = player_in_mission.shield.scene.instantiate() as PlayerShield
	shield.post_ready_prepare(Application.ConceptMode.InHud)
	shield.position = Vector2(16, 16)
	$PlayerInfo/Layout/Shield/SubViewport.add_child(shield)
	$PlayerInfo/Layout/ProjectilesCnt/Regen/Factor.max_value = player_in_mission.weapon.max_projectiles_cnt

#endregion

#region Game logic

func update_player(player: Player, effect: Player.PlayerEffect) -> void:
	$PlayerInfo/Layout/Life/Text.text = str(player.life)
	$PlayerInfo/Layout/Speed/Text.text = str(player.speed)
	if player.speed_regen_factor > 0:
		$PlayerInfo/Layout/Speed/Regen/Factor.value = player.speed_regen_factor / player.SPEED_REGEN_CUTOFF * 100
	else:
		$PlayerInfo/Layout/Speed/Regen/Factor.value = 0
	$PlayerInfo/Layout/ProjectilesCnt/Text.text = str(player.projectiles_cnt)
	if player.projectiles_cnt_regen_factor > 0:
		$PlayerInfo/Layout/ProjectilesCnt/Regen/Factor.value = player.projectiles_cnt_regen_factor
	else:
		$PlayerInfo/Layout/ProjectilesCnt/Regen/Factor.value = 0
		
	_enqueue_effect_log(effect)
		
func update_mission(mission_state: Game.MissionState, dark_towers_left_cnt: int, bosses_left_cnt: int, score: int) -> void:
	$MissionInfo/Right/DarkTowersLeftCnt/Text.text = str(dark_towers_left_cnt)
	$MissionInfo/Right/BossesLeftCnt/Text.text = str(bosses_left_cnt)
	$MissionInfo/Score/Text.text = str(score)
	
	match mission_state:
		Game.MissionState.Start:
			$PlayerInfo.hide()
			$MissionInfo.hide()
			$MissionInfo/Score.hide()
			$MissionInfo/Right/DarkTowersLeftCnt.hide()
			$MissionInfo/Right/BossesLeftCnt.hide()
		Game.MissionState.GetReady:
			$PlayerInfo.show()
			$MissionInfo.show()
			$MissionInfo/Score.hide()
			$MissionInfo/Right/DarkTowersLeftCnt.hide()
			$MissionInfo/Right/BossesLeftCnt.hide()
		Game.MissionState.DestroyDarkTowers:
			$PlayerInfo.show()
			$MissionInfo.show()
			$MissionInfo/Score.show()
			$MissionInfo/Right/DarkTowersLeftCnt.show()
			$MissionInfo/Right/BossesLeftCnt.hide()
		Game.MissionState.BossFight:
			$PlayerInfo.show()
			$MissionInfo.show()
			$MissionInfo/Score.show()
			$MissionInfo/Right/DarkTowersLeftCnt.hide()
			$MissionInfo/Right/BossesLeftCnt.show()
			
			
func _enqueue_effect_log(effect: Player.PlayerEffect) -> void:
	if effect == Player.PlayerEffect.NONE:
		return
		
	effects_log.append(effect.message)
	effects_log_timer.append(int(EFFECTS_LOG_DISPLAY_SEC / $EffectsLog/Clear.wait_time))
	
func _process_effects_log() -> void:
	if len(effects_log) > 0 and effects_log_timer[0] == 0:
		effects_log.pop_front()
		effects_log_timer.pop_front()
	
	if len(effects_log) == 0:
		$EffectsLog.hide()
		$EffectsLog/One.text = ""
		$EffectsLog/Two.text = ""
	elif len(effects_log) == 1:
		$EffectsLog.show()
		$EffectsLog/One.text = effects_log[0]
		$EffectsLog/Two.text = ""
	elif len(effects_log) == 2:
		$EffectsLog.show()
		$EffectsLog/One.text = effects_log[0]
		$EffectsLog/Two.text = effects_log[1]
	else:
		$EffectsLog.show()
		$EffectsLog/One.text = effects_log[0]
		$EffectsLog/Two.text = "{message} and {len} others".format({"message": effects_log[1], "len": len(effects_log) - 2})
		
	# First two log messages, if they exist get decremented.
	if len(effects_log) > 0:
		effects_log_timer[0] = effects_log_timer[0] - 1
	if len(effects_log) > 1:
		effects_log_timer[1] = effects_log_timer[1] - 1
		
#endregion
