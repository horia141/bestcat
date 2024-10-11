class_name Game
extends Node2D

signal quit_mission ()

const LifePowerUpScn = preload("res://entities/treasures/life-powerup/life-powerup.tscn")
const ProjectilePowerUpScn = preload("res://entities/treasures/projectile-powerup/projectile-powerup.tscn")

var dark_towers_left_cnt = 0

#region Construction

@onready var mission = $Mission

func _ready() -> void:
	$GameCamera.post_ready_prepare($BestCat/Follow, mission.get_node("Level").size_in_px)
	 
	$BestCat.state_change.connect(func (): $HUD.update_player($BestCat))
	$BestCat.post_ready_prepare(mission.get_node("PlayerStartPosition").global_position)
	
	for structure in get_tree().get_nodes_in_group("Structures"):
		var the_structure = structure as Structure
		if the_structure is DarkTower:
			dark_towers_left_cnt += 1
			the_structure.post_ready_prepare()
			the_structure.spawned_enemy.connect(_on_dark_tower_spawns_enemy)
			the_structure.destroyed.connect(func (): _on_dark_tower_destroyed(the_structure))
	
	for player in get_tree().get_nodes_in_group("Players"):
		var the_player = player as Player
		the_player.shoot.connect(_on_player_shoot)
		
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var the_enemy = enemy as Enemy
		the_enemy.shoot.connect(_on_enemy_shoot)
		the_enemy.destroyed.connect(func (): _on_enemy_destroyed(the_enemy))
		
	for treasure in get_tree().get_nodes_in_group("Treasures"):
		var the_treasure = treasure as Treasure
		the_treasure.picked_up.connect(func (player): _on_treasure_picked(player, the_treasure))
		
	$HUD.update_player($BestCat)
	$HUD.update_mission(dark_towers_left_cnt)
	
	mission = $Mission
		
func post_ready_prepare(mission_path: String) -> void:
	var mission_scn = load(mission_path)
	if mission != null:
		print(mission)
		remove_child(mission)
		mission.queue_free()
	mission = mission_scn.instantiate()
	add_child(mission)
	
	$GameCamera.post_ready_prepare($BestCat/Follow, mission.get_node("Level").size_in_px)
	 
	$BestCat.state_change.connect(func (): $HUD.update_player($BestCat))
	$BestCat.post_ready_prepare(mission.get_node("PlayerStartPosition").global_position)
	
	for structure in get_tree().get_nodes_in_group("Structures"):
		var the_structure = structure as Structure
		if the_structure is DarkTower:
			dark_towers_left_cnt += 1
			the_structure.post_ready_prepare()
			the_structure.spawned_enemy.connect(_on_dark_tower_spawns_enemy)
			the_structure.destroyed.connect(func (): _on_dark_tower_destroyed(the_structure))
	
	for player in get_tree().get_nodes_in_group("Players"):
		var the_player = player as Player
		the_player.shoot.connect(_on_player_shoot)
		
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var the_enemy = enemy as Enemy
		the_enemy.shoot.connect(_on_enemy_shoot)
		the_enemy.destroyed.connect(func (): _on_enemy_destroyed(the_enemy))
		
	for treasure in get_tree().get_nodes_in_group("Treasures"):
		var the_treasure = treasure as Treasure
		the_treasure.picked_up.connect(func (player): _on_treasure_picked(player, the_treasure))
		
	$HUD.update_player($BestCat)
	$HUD.update_mission(dark_towers_left_cnt)
	
#endregion

#region Game logic

func _on_player_shoot(player_projectile: PlayerProjectile) -> void:
	add_child(player_projectile)
	player_projectile.enemy_hit.connect(_on_projectile_hit_enemy)
	player_projectile.structure_hit.connect(_on_player_projectile_hit_structure)
	
func _on_enemy_shoot(enemy_projectile: EnemyProjectile) -> void:
	add_child(enemy_projectile)
	enemy_projectile.player_hit.connect(_on_projectile_hit_player)
	
func _on_enemy_destroyed(enemy: Enemy) -> void:
	if randf_range(0, 1) < 0.5:
		var life_powerup = LifePowerUpScn.instantiate()
		life_powerup.post_ready_prepare(enemy.position)
		life_powerup.picked_up.connect(func (player): _on_treasure_picked(player, life_powerup))
		call_deferred("add_child", life_powerup)
	else:
		var projectile_powerup = ProjectilePowerUpScn.instantiate()
		projectile_powerup.post_ready_prepare(enemy.position)
		projectile_powerup.picked_up.connect(func (player): _on_treasure_picked(player, projectile_powerup))
		call_deferred("add_child", projectile_powerup)
		
	for dark_tower in get_tree().get_nodes_in_group("Structures"):
		if dark_tower is DarkTower:
			dark_tower.on_own_spawn_destroyed(enemy)
		
func _on_treasure_picked(player: Player, treasure: Treasure) -> void:
	player.apply_treasure(treasure)
	
func _on_player_projectile_hit_structure(structure: Structure) -> void:
	structure.on_hit_by_player_projectile()

func _on_projectile_hit_enemy(enemy: Enemy) -> void:
	enemy.on_hit_by_projectile()
	
func _on_projectile_hit_player(player: Player) -> void:
	player.on_hit_by_projectile()
	
func _on_dark_tower_spawns_enemy(enemy: Enemy) -> void:
	# We'll do some adjustments to the enemy position so it's not
	# in an inaccessible place.
	var new_position = mission.get_node("Level").get_appropriate_pos_for_enemy(enemy)
	enemy.position = new_position
	add_child(enemy)
	enemy.shoot.connect(_on_enemy_shoot)
	enemy.destroyed.connect(func (): _on_enemy_destroyed(enemy))
	
func _on_dark_tower_destroyed(dark_tower: DarkTower) -> void:
	dark_towers_left_cnt -= 1
	$HUD.update_mission(dark_towers_left_cnt)
	
func _quit_mission() -> void:
	quit_mission.emit()

#endregion
