class_name DarkTower
extends Structure

const JellyScn = preload("res://entities/enemies/mobs/jelly/jelly.tscn")
const OgreScn = preload("res://entities/enemies/mobs/ogre/ogre.tscn")

signal spawned_mob (mob: Mob)
signal destroyed ()

static var SPAWN_PERIOD_SEC = DifficultyValue.new(5, 4, 3)
static var MAX_MOBS_TO_SPAWN = DifficultyValue.new(3, 5, 7)
static var MAX_LIFE = DifficultyValue.new(2, 3, 5)

var life = MAX_LIFE.get_for(difficulty)
var my_mobs = {}

#region Construction

func _ready() -> void:
	$HealthBar.max_life = MAX_LIFE.get_for(difficulty)
	$HealthBar.life = life
	
func post_ready_prepare(difficulty: Application.MissionDifficulty) -> void:
	super.post_ready_prepare(difficulty)
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
		
	if randf_range(0, 1) < 0.5:
		var jelly = JellyScn.instantiate()
		jelly.post_ready_prepare(_random_position_in_disc(position), difficulty)
		spawned_mob.emit(jelly)
		my_mobs[jelly.get_instance_id()] = jelly
	else:
		var ogre = OgreScn.instantiate()
		ogre.post_ready_prepare(_random_position_in_disc(position), difficulty)
		spawned_mob.emit(ogre)
		my_mobs[ogre.get_instance_id()] = ogre
		
	$SpawnTimer.wait_time = SPAWN_PERIOD_SEC.get_for(difficulty) + randf_range(-0.5, 0.5)
	$SpawnTimer.start()
		

func on_own_spawn_destroyed(mob: Mob) -> void:
	if not my_mobs.has(mob.get_instance_id()):
		return
		
	my_mobs.erase(mob.get_instance_id())

func on_hit_by_player_projectile() -> void:
	if state == StructureState.Destroyed:
		return
		
	life = max(life - 1, 0)
	$HealthBar.life = life
	
	if life == 0:
		state = StructureState.Destroyed
		
		$SpawnTimer.stop()
		
		$Explosion.visible = true
		$Explosion.play("explosion")
		
		$BaseSprite.play("destroyed")
		await $Explosion.animation_finished
		
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
