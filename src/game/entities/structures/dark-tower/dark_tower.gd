class_name DarkTower
extends Structure

const JellyScn = preload("res://entities/enemies/mobs/jelly/jelly.tscn")
const SnailScn = preload("res://entities/enemies/mobs/snail/snail.tscn")
const OgreScn = preload("res://entities/enemies/mobs/ogre/ogre.tscn")
const ActivationAreaScn = preload("res://entities/enemies/activation-area/enemy-activation-area.tscn")

signal spawned_mob (mob: Mob)
signal destroyed ()

static var SPAWN_PERIOD_SEC = DifficultyValue.new(5, 4, 3)
static var MAX_MOBS_TO_SPAWN = DifficultyValue.new(3, 5, 7)
static var MAX_LIFE = DifficultyValue.new(2, 3, 4)

var life = MAX_LIFE.get_for(difficulty)
var my_mobs = {}

#region Construction

func _ready() -> void:
	$HealthBar.max_life = MAX_LIFE.get_for(difficulty)
	$HealthBar.life = life
	
func post_ready_prepare(player: Game.PlayerProxy, difficulty: Application.MissionDifficulty) -> void:
	super.post_ready_prepare(player, difficulty)
	life = MAX_LIFE.get_for(difficulty)
	$HealthBar.max_life = MAX_LIFE.get_for(difficulty)
	$HealthBar.life = life

#endregion

#region Game logic

func _spawn_mob() -> void:
	if state == StructureState.Destroyed:
		return

	if my_mobs.size() >= MAX_MOBS_TO_SPAWN.get_for(difficulty):
		return
		
	var activation_area = ActivationAreaScn.instantiate()
	activation_area.scale = Vector2(2, 2)
	
	var choice = randf_range(0, 1)
	if choice < 0.33:
		var jelly = JellyScn.instantiate()
		jelly.add_child(activation_area)
		jelly.post_ready_prepare(player, _random_position_in_disc(position), difficulty)
		spawned_mob.emit(jelly)
		my_mobs[jelly.get_instance_id()] = jelly
	elif choice < 0.66:
		var snail = SnailScn.instantiate()
		snail.add_child(activation_area)
		snail.post_ready_prepare(player, _random_position_in_disc(position), difficulty)
		spawned_mob.emit(snail)
		my_mobs[snail.get_instance_id()] = snail
	else:
		var ogre = OgreScn.instantiate()
		ogre.add_child(activation_area)
		ogre.post_ready_prepare(player, _random_position_in_disc(position), difficulty)
		spawned_mob.emit(ogre)
		my_mobs[ogre.get_instance_id()] = ogre
		
	$SpawnTimer.wait_time = SPAWN_PERIOD_SEC.get_for(difficulty) + randf_range(-0.5, 0.5)
	$SpawnTimer.start()
		

func on_own_spawn_destroyed(mob: Mob) -> void:
	if not my_mobs.has(mob.get_instance_id()):
		return
		
	my_mobs.erase(mob.get_instance_id())

func on_hit_by_player_projectile() -> void:
	super.on_hit_by_player_projectile()

	if state == StructureState.Destroyed:
		return
		
	life = max(life - 1, 0)
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
		mob.on_hit_by_projectile()
		
	destroyed.emit()

#endregion

#region Helpers

func _random_position_in_disc(center: Vector2, min_radius: float = 32, max_radius: float = 200) -> Vector2:
	# Generate a random angle in radians (0 to 2 * PI)
	var angle = randf() * TAU  # TAU is 2π (360 degrees)
		
	# Generate a random radius with uniform distribution
	var radius = sqrt(randf()) * (max_radius - min_radius) + min_radius

	# Convert polar coordinates to Cartesian coordinates
	var random_offset = Vector2(radius * cos(angle), radius * sin(angle))
		
	# Return the random position within the disc
	return center + random_offset

#endregion
