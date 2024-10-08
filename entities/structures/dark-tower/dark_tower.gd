class_name DarkTower
extends Structure

const JellyScn = preload("res://entities/enemies/jelly/jelly.tscn")
const OgreScn = preload("res://entities/enemies/ogre/ogre.tscn")

signal spawned_enemy (enemy: Enemy)
signal destroyed ()

const SPAWN_PERIOD_SEC = 5
const MAX_ENEMIES_TO_SPAWN = 5
const MAX_LIFE = 3

var life = MAX_LIFE
var my_enemies = {}

#region Construction

func _ready() -> void:
	pass
	
func post_ready_prepare() -> void:
	pass

#endregion

#region Game logic

func _spawn_enemy() -> void:
	if state == StructureState.Destroyed:
		return

	if my_enemies.size() >= MAX_ENEMIES_TO_SPAWN:
		return
		
	if randf_range(0, 1) < 0.5:
		var jelly = JellyScn.instantiate()
		jelly.post_ready_prepare(_random_position_in_disc(position))
		spawned_enemy.emit(jelly)
		my_enemies[jelly.get_instance_id()] = jelly
	else:
		var ogre = OgreScn.instantiate()
		ogre.post_ready_prepare(_random_position_in_disc(position))
		spawned_enemy.emit(ogre)
		my_enemies[ogre.get_instance_id()] = ogre
		
	$SpawnTimer.wait_time = SPAWN_PERIOD_SEC + randf_range(-0.5, 0.5)
	$SpawnTimer.start()
		

func on_own_spawn_destroyed(enemy: Enemy) -> void:
	if not my_enemies.has(enemy.get_instance_id()):
		return
		
	my_enemies.erase(enemy.get_instance_id())

func on_hit_by_player_projectile() -> void:
	if state == StructureState.Destroyed:
		return
		
	life = max(life - 1, 0)
	
	if life == 0:
		state = StructureState.Destroyed
		
		destroyed.emit()
		
		$SpawnTimer.stop()
		
		$Explosion.visible = true
		$Explosion.play("explosion")
		
		$BaseSprite.play("destroyed")
		await $Explosion.animation_finished
		await $BaseSprite.animation_finished

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
