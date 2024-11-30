class_name DarkTower
extends Structure

const JellyScn = preload("res://entities/enemies/mobs/jelly/jelly.tscn")
const SnailScn = preload("res://entities/enemies/mobs/snail/snail.tscn")
const OgreScn = preload("res://entities/enemies/mobs/ogre/ogre.tscn")
const ActivationAreaScn = preload("res://entities/enemies/activation-area/enemy-activation-area.tscn")

signal spawned_mob (mob: Mob)
signal destroyed ()

const SPAWN_DISTANCE_MIN = 32.0
const SPAWN_DISTANCE_MAX = 200.0
static var SPAWN_PERIOD_SEC = DifficultyValue.new(5, 4, 3)
static var MAX_MOBS_TO_SPAWN = DifficultyValue.new(3, 5, 7)
static var MAX_LIFE = DifficultyValue.new(2, 3, 4)

var all_mobs_desc: Array[Application.EnemyDesc] = []
var life = MAX_LIFE.get_for(difficulty)
var my_mobs = {}
var ok_cell_pos_for_gen: Array[Vector2] = []

#region Construction

func _ready() -> void:
	$HealthBar.max_life = MAX_LIFE.get_for(difficulty)
	$HealthBar.life = life
	
func post_ready_prepare(all_mobs_desc: Array[Application.EnemyDesc], player: Game.PlayerProxy, difficulty: Application.MissionDifficulty, terrain_map: Mission.TerrainMap) -> void:
	super.post_ready_prepare(all_mobs_desc, player, difficulty, terrain_map)
	self.all_mobs_desc = all_mobs_desc
	life = MAX_LIFE.get_for(difficulty)
	$HealthBar.max_life = MAX_LIFE.get_for(difficulty)
	$HealthBar.life = life
	
	ok_cell_pos_for_gen = []
	var gen_position = $GenCenter.global_position
	for row_idx in range(0, terrain_map.rows_cnt):
		for col_idx in range(0, terrain_map.cols_cnt):
			var row_pos = row_idx * terrain_map.cells_size.y
			var col_pos = col_idx * terrain_map.cells_size.x
			var cell_dist = gen_position.distance_to(Vector2(col_pos, row_pos))
			
			var neigh_cells_cnt = 0
			neigh_cells_cnt += 1 if __check_cell_for_inclusion(gen_position, row_idx - 1, col_idx - 1, terrain_map) else 0
			neigh_cells_cnt += 1 if __check_cell_for_inclusion(gen_position, row_idx - 1, col_idx + 0, terrain_map) else 0
			neigh_cells_cnt += 1 if __check_cell_for_inclusion(gen_position, row_idx - 1, col_idx + 1, terrain_map) else 0
			neigh_cells_cnt += 1 if __check_cell_for_inclusion(gen_position, row_idx + 0, col_idx - 1, terrain_map) else 0
			neigh_cells_cnt += 1 if __check_cell_for_inclusion(gen_position, row_idx + 0, col_idx + 0, terrain_map) else 0
			neigh_cells_cnt += 1 if __check_cell_for_inclusion(gen_position, row_idx + 0, col_idx + 1, terrain_map) else 0
			neigh_cells_cnt += 1 if __check_cell_for_inclusion(gen_position, row_idx + 1, col_idx - 1, terrain_map) else 0
			neigh_cells_cnt += 1 if __check_cell_for_inclusion(gen_position, row_idx + 1, col_idx + 0, terrain_map) else 0
			neigh_cells_cnt += 1 if __check_cell_for_inclusion(gen_position, row_idx + 1, col_idx + 1, terrain_map) else 0
			
			if neigh_cells_cnt > 8:
				ok_cell_pos_for_gen.push_back(Vector2(col_pos, row_pos))

	#for cell in ok_cell_pos_for_gen:
		#var new_disp = TextureRect.new()
		#new_disp.texture = CanvasTexture.new()
		#new_disp.modulate = Color.BLUE
		#new_disp.position.x = cell.x
		#new_disp.position.y = cell.y
		#new_disp.size.x = 8
		#new_disp.size.y = 8
		#new_disp.z_index = 1000
		#get_parent().add_child(new_disp)
		
func __check_cell_for_inclusion(gen_position: Vector2, row_idx: int, col_idx: int, terrain_map: Mission.TerrainMap) -> bool:
	if not (row_idx >= 0 and row_idx < terrain_map.rows_cnt):
		return false
	if not (col_idx >= 0 and col_idx < terrain_map.cols_cnt):
		return false

	var row_pos = row_idx * terrain_map.cells_size.y
	var col_pos = col_idx * terrain_map.cells_size.x
	var cell_dist = gen_position.distance_to(Vector2(col_pos, row_pos))
	
	return cell_dist > SPAWN_DISTANCE_MIN and \
			cell_dist < SPAWN_DISTANCE_MAX and \
			not terrain_map.get_cell(row_idx, col_idx).is_blocked
			
#endregion

#region Game logic

func _spawn_mob() -> void:
	if state == StructureState.Destroyed:
		return

	if my_mobs.size() >= MAX_MOBS_TO_SPAWN.get_for(difficulty):
		$SpawnTimer.wait_time = SPAWN_PERIOD_SEC.get_for(difficulty) + randf_range(-0.5, 0.5)
		$SpawnTimer.start()
		return
		
	$BaseSprite.play("generate")
	await $BaseSprite.animation_finished
	if state == StructureState.Destroyed:
		# Was destroyed in the meanwhile
		return
	$BaseSprite.play("idle")

	var activation_area = ActivationAreaScn.instantiate()
	activation_area.scale = Vector2(3, 3)
	
	var random_mob_desc = all_mobs_desc.pick_random()
	var random_mob = random_mob_desc.scene.instantiate()
	random_mob.add_child(activation_area)
	random_mob.post_ready_prepare(random_mob.Desc, player, _random_position_in_disc(), difficulty)
	spawned_mob.emit(random_mob)
	my_mobs[random_mob.get_instance_id()] = random_mob
		
	$SpawnTimer.wait_time = SPAWN_PERIOD_SEC.get_for(difficulty) + randf_range(-0.5, 0.5)
	$SpawnTimer.start()
		

func on_own_spawn_destroyed(mob: Mob) -> void:
	if not my_mobs.has(mob.get_instance_id()):
		return
		
	my_mobs.erase(mob.get_instance_id())

func on_hit_by_player_projectile(projectile: PlayerProjectile) -> void:
	super.on_hit_by_player_projectile(projectile)

	if state == StructureState.Destroyed:
		return
		
	life = max(life - projectile.damage, 0)
	$HealthBar.life = life
	
	if life == 0:
		destroy()
		
		
func destroy():
	super.destroy()
	state = StructureState.Destroyed
		
	$SpawnTimer.stop()
		
	$Explosion.visible = true
	$Explosion.play("explosion")

	$BaseSprite.play("destroyed")
	await $Explosion.animation_finished
		
	# Destroy some of our active mobs
	for mob in my_mobs.values():
		if not mob.is_bound_to_dark_tower():
			continue
		mob.destroy()
		
	destroyed.emit()

#endregion

#region Helpers

func _random_position_in_disc() -> Vector2:
	return ok_cell_pos_for_gen.pick_random()

#endregion
