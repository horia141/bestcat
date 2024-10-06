class_name Game
extends Node

const LifePowerUpScn = preload("res://entities/treasures/life-powerup/life-powerup.tscn")
const ProjectilePowerUpScn = preload("res://entities/treasures/projectile-powerup/projectile-powerup.tscn")

#region Construction

func _ready() -> void:
	var level_size_in_cells = $Level/Terrain.get_used_rect().size
	var tile_size_in_px = $Level/Terrain.tile_set.tile_size
	var level_size_in_px = level_size_in_cells * tile_size_in_px
	
	$BestCat.post_ready_prepare(level_size_in_px)
	$BestCat.state_change.connect(func (): $HUD.update($BestCat))
	
	for player in get_tree().get_nodes_in_group("Players"):
		(player as Player).shoot.connect(_on_player_shoot)
		
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var the_enemy = enemy as Enemy
		the_enemy.shoot.connect(_on_enemy_shoot)
		the_enemy.destroyed.connect(func (): _on_enemy_destroyed(the_enemy))
		
	for treasure in get_tree().get_nodes_in_group("Treasures"):
		var the_treasure = treasure as Treasure
		the_treasure.picked_up.connect(func (player): _on_treasure_picked(player, the_treasure))
		
func post_ready_prepare() -> void:
	pass
	
#endregion

#region Game logic

func _on_player_shoot(player_projectile: PlayerProjectile) -> void:
	add_child(player_projectile)
	player_projectile.enemy_hit.connect(_on_projectile_hit_enemy)
	
func _on_enemy_shoot(enemy_projectile: EnemyProjectile) -> void:
	add_child(enemy_projectile)
	enemy_projectile.player_hit.connect(_on_projectile_hit_player)
	
func _on_enemy_destroyed(enemy: Enemy) -> void:
	if randf_range(0, 1) < 0.5:
		var life_powerup = LifePowerUpScn.instantiate()
		life_powerup.post_ready_prepare(enemy.position)
		life_powerup.picked_up.connect(func (player): _on_treasure_picked(player, life_powerup))
		add_child(life_powerup)
	else:
		var projectile_powerup = ProjectilePowerUpScn.instantiate()
		projectile_powerup.post_ready_prepare(enemy.position)
		projectile_powerup.picked_up.connect(func (player): _on_treasure_picked(player, projectile_powerup))
		add_child(projectile_powerup)
		
func _on_treasure_picked(player: Player, treasure: Treasure) -> void:
	player.apply_treasure(treasure)

func _on_projectile_hit_enemy(enemy: Enemy) -> void:
	enemy.on_hit_by_projectile()
	
func _on_projectile_hit_player(player: Player) -> void:
	player.on_hit_by_projectile()
	
#endregion
