class_name Game
extends Node2D

signal won_mission ()
signal retry_mission ()
signal quit_mission ()

enum MissionState {
	Start,
	GetReady,
	DestroyDarkTowers,
	BossFight
}

const LifePowerUpScn = preload("res://entities/treasures/life-powerup/life-powerup.tscn")
const ProjectilePowerUpScn = preload("res://entities/treasures/projectile-powerup/projectile-powerup.tscn")

const DEFAULT_DIFFICULTY = Application.MissionDifficulty.Apprentice

@onready var mission: Mission = $Mission
var mission_config: Application.MissionConfig = null
var mission_state = MissionState.Start
var dark_towers_left_cnt = 0
var bosses_left_cnt = 0
var score = 0

#region Construction

func _ready() -> void:
	# We want this thing to be runnable outside of the application,
	# so we wire it up like this. But the common path is in
	# post_ready_prepare.
	_wire_up_everything(true)
		
func post_ready_prepare(new_mission_config: Application.MissionConfig) -> void:
	if mission != null:
		remove_child(mission)
		mission.queue_free()
		mission_state = MissionState.Start
		dark_towers_left_cnt = 0
		bosses_left_cnt = 0
		score = 0
		mission_config = null
		# Wait till the next frame so everything is freed
		await get_tree().process_frame
	mission = new_mission_config.desc.scene.instantiate()
	mission_config = new_mission_config
	add_child(mission)
	_wire_up_everything(false)
	
func _wire_up_everything(_in_ready: bool) -> void:
	$GameCamera.post_ready_prepare($BestCat/Follow, mission.size_in_px)
	 
	$BestCat.state_change.connect(func (): $HUD.update_player($BestCat))
	$BestCat.post_ready_prepare(mission.get_node("PlayerStartPosition").global_position, mission_config.difficulty if mission_config else DEFAULT_DIFFICULTY)
	
	for structure in get_tree().get_nodes_in_group("Structures"):
		var the_structure = structure as Structure
		if the_structure is DarkTower:
			dark_towers_left_cnt += 1
			the_structure.post_ready_prepare(mission_config.difficulty if mission_config else DEFAULT_DIFFICULTY)
			the_structure.spawned_mob.connect(_on_dark_tower_spawns_mob)
			the_structure.destroyed.connect(func (): _on_dark_tower_destroyed(the_structure))
	
	for player in get_tree().get_nodes_in_group("Players"):
		var the_player = player as Player
		the_player.shoot.connect(_on_player_shoot)
		the_player.destroyed.connect(_on_player_destroyed)
		
	for mob in get_tree().get_nodes_in_group("Mobs"):
		var the_mob = mob as Mob
		the_mob.post_ready_prepare(the_mob.position, mission_config.difficulty if mission_config else DEFAULT_DIFFICULTY)
		the_mob.shoot.connect(_on_enemy_shoot)
		the_mob.destroyed.connect(func (): _on_mob_destroyed(the_mob))
		
	for boss in get_tree().get_nodes_in_group("Bosses"):
		var the_boss = boss as Boss
		bosses_left_cnt += 1
		the_boss.hide()
		the_boss.post_ready_prepare(the_boss.position, mission_config.difficulty if mission_config else DEFAULT_DIFFICULTY)
		the_boss.shoot.connect(_on_enemy_shoot)
		the_boss.state_change.connect(func (): _on_boss_change_state(the_boss))
		the_boss.destroyed.connect(func (): _on_boss_destroyed(the_boss))
		
	for treasure in get_tree().get_nodes_in_group("Treasures"):
		var the_treasure = treasure as Treasure
		the_treasure.picked_up.connect(func (player): _on_treasure_picked(player, the_treasure))
		
	$HUD.update_player($BestCat)
	$HUD.update_mission(mission_state, dark_towers_left_cnt, bosses_left_cnt, score)
	
	__hide_dialogs() # TODO: this should be some big interaction manager
	
	get_tree().paused = true
	
	mission.advance_to_story_checkpoint(Story.StoryCheckpoint.MissionStart)
	await mission.story_checkpoint_processed

	mission_state = MissionState.GetReady
	
	$HUD.update_mission(mission_state, dark_towers_left_cnt, bosses_left_cnt, score)
	
	$StartCountdown.show()
	$StartCountdown.begin()
	
#endregion

#region Game logic

func _got_ready() -> void:
	mission_state = MissionState.DestroyDarkTowers
	$HUD.update_mission(mission_state, dark_towers_left_cnt, bosses_left_cnt, score)
	$StartCountdown.queue_free()
	get_tree().paused = false

func _on_player_shoot(player_projectile: PlayerProjectile) -> void:
	add_child(player_projectile)
	player_projectile.enemy_hit.connect(_on_projectile_hit_enemy)
	player_projectile.structure_hit.connect(_on_player_projectile_hit_structure)
	player_projectile.otherwise_destroyed.connect(func (): _on_player_projectile_destroyed(player_projectile))
	
func _on_player_destroyed() -> void:
	$BestCat.queue_free()
	get_tree().paused = true
	mission.advance_to_story_checkpoint(Story.StoryCheckpoint.MissionEndFailure)
	await mission.story_checkpoint_processed
	__hide_dialogs()
	$LoseDialog.activate()
	
func _on_enemy_shoot(enemy_projectile: EnemyProjectile) -> void:
	add_child(enemy_projectile)
	enemy_projectile.player_hit.connect(_on_projectile_hit_player)
	enemy_projectile.otherwise_destroyed.connect(func (): _on_enemy_projectile_destroyed(enemy_projectile))
	
func _on_mob_destroyed(mob: Mob) -> void:
	mob.queue_free()
	
	if randf_range(0, 1) < 0.5:
		var life_powerup = LifePowerUpScn.instantiate()
		life_powerup.post_ready_prepare(mob.position)
		life_powerup.picked_up.connect(func (player): _on_treasure_picked(player, life_powerup))
		call_deferred("add_child", life_powerup)
	else:
		var projectile_powerup = ProjectilePowerUpScn.instantiate()
		projectile_powerup.post_ready_prepare(mob.position)
		projectile_powerup.picked_up.connect(func (player): _on_treasure_picked(player, projectile_powerup))
		call_deferred("add_child", projectile_powerup)
		
	score += 1
	$HUD.update_mission(mission_state, dark_towers_left_cnt, bosses_left_cnt, score)
		
	for dark_tower in get_tree().get_nodes_in_group("Structures"):
		if dark_tower is DarkTower:
			dark_tower.on_own_spawn_destroyed(mob)
			
func _on_boss_change_state(boss: Boss) -> void:
	pass
	
func _on_boss_destroyed(boss: Boss) -> void:
	boss.queue_free()

	bosses_left_cnt -= 1
	score += 10
	$HUD.update_mission(mission_state, dark_towers_left_cnt, bosses_left_cnt, score)
	
	get_tree().paused = true
	mission.advance_to_story_checkpoint(Story.StoryCheckpoint.MissionBeatBoss)
	await mission.story_checkpoint_processed
	get_tree().paused = true
	
	if bosses_left_cnt == 0:
		get_tree().paused = true
		mission.advance_to_story_checkpoint(Story.StoryCheckpoint.MissionEndSuccess)
		await mission.story_checkpoint_processed
		__hide_dialogs()
		$WinDialog.activate()
		
func _on_treasure_picked(player: Player, treasure: Treasure) -> void:
	player.apply_treasure(treasure)
	treasure.queue_free()
	
func _on_player_projectile_hit_structure(structure: Structure) -> void:
	structure.on_hit_by_player_projectile()
	
func _on_player_projectile_destroyed(player_projectile: PlayerProjectile) -> void:
	player_projectile.queue_free()

func _on_projectile_hit_enemy(enemy: Enemy) -> void:
	enemy.on_hit_by_projectile()
	
func _on_projectile_hit_player(player: Player) -> void:
	player.on_hit_by_projectile()
	score = max(0, score - 1)
	$HUD.update_mission(mission_state, dark_towers_left_cnt, bosses_left_cnt, score)
	
func _on_enemy_projectile_destroyed(enemy_projectile: EnemyProjectile) -> void:
	enemy_projectile.queue_free()
	
func _on_dark_tower_spawns_mob(mob: Mob) -> void:
	# We'll do some adjustments to the enemy position so it's not
	# in an inaccessible place.
	var new_position = mission.get_appropriate_pos_for_enemy(mob)
	mob.position = new_position
	add_child(mob)
	mob.shoot.connect(_on_enemy_shoot)
	mob.destroyed.connect(func (): _on_mob_destroyed(mob))
	
func _on_dark_tower_destroyed(dark_tower: DarkTower) -> void:
	dark_towers_left_cnt -= 1
	score += 3
	
	if dark_towers_left_cnt == 0:
		get_tree().paused = true
		mission.advance_to_story_checkpoint(Story.StoryCheckpoint.MissionBeatDarkTowers)
		await mission.story_checkpoint_processed
		get_tree().paused = false
		
		mission_state = MissionState.BossFight
		for boss in get_tree().get_nodes_in_group("Bosses"):
			var the_boss = boss as Boss
			the_boss.show()
			the_boss.activate()
		
	$HUD.update_mission(mission_state, dark_towers_left_cnt, bosses_left_cnt, score)
	
func _drain_score_periodically() -> void:
	score = max(0, score - 1)
	$HUD.update_mission(mission_state, dark_towers_left_cnt, bosses_left_cnt, score)
	
#region Lifecycle events (many controlled through dialogs)

func _show_pause_dialog() -> void:
	__hide_dialogs()
	$PauseDialog.activate()
	get_tree().paused = true
	
func _show_help_dialog() -> void:
	__hide_dialogs()
	$HelpDialog.activate()
	get_tree().paused = true
	
func _resume_mission() -> void:
	__hide_dialogs()
	get_tree().paused = false
	
func _retry_mission() -> void:
	__hide_dialogs()
	get_tree().paused = false
	retry_mission.emit()
	
func _quit_mission() -> void:
	__hide_dialogs()
	get_tree().paused = false
	quit_mission.emit()
	
func _won_mission() -> void:
	__hide_dialogs()
	get_tree().paused = false
	won_mission.emit()
	
func __hide_dialogs() -> void:
	for dialog in get_tree().get_nodes_in_group("Dialogs"):
		dialog.hide()
		
#endregion

#endregion

#region Game events

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Mission Pause"):
		_show_pause_dialog()
	elif event.is_action_pressed("Help With Controls"):
		_show_help_dialog()
