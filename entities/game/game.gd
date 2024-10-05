class_name Game
extends Node


func _ready() -> void:
	var level_size_in_cells = $Level/Terrain.get_used_rect().size
	var tile_size_in_px = $Level/Terrain.tile_set.tile_size
	var level_size_in_px = level_size_in_cells * tile_size_in_px
	
	$BestCat.post_ready_prepare(level_size_in_px)
	$BestCat.shoot.connect(_on_player_shoot)
	
	$Ogre1.shoot.connect(_on_enemy_shoot)
	$Ogre2.shoot.connect(_on_enemy_shoot)
	$Ogre3.shoot.connect(_on_enemy_shoot)
	$Ogre4.shoot.connect(_on_enemy_shoot)
	$Jelly1.shoot.connect(_on_enemy_shoot)


func _on_player_shoot(player_projectile: PlayerProjectile) -> void:
	add_child(player_projectile)
	player_projectile.enemy_hit.connect(_on_projectile_hit_enemy)
	
func _on_enemy_shoot(enemy_projectile: EnemyProjectile) -> void:
	add_child(enemy_projectile)
	enemy_projectile.player_hit.connect(_on_projectile_hit_player)
	
func _on_projectile_hit_enemy(enemy: Enemy) -> void:
	enemy.on_hit_by_projectile()
	
func _on_projectile_hit_player(player: BestCat) -> void:
	player.on_hit_by_projectile()
	$HUD.update_life(player.life)
