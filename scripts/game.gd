extends Node2D

@export var asteroid_spawn_probability := 0.04
@export var broken_craft_spawn_probability := 0.01
@export var max_projectile_count := 100

@export var projectiles: Node
@export var rockets: Node
@export var players: Node

@onready var pause_screen := $UI/PauseScreen as Control
@onready var hud := $UI/HUD as HUD

var asteroid_scene := preload("res://scenes/asteroid.tscn")
var broken_craft_scene := preload("res://scenes/broken_craft.tscn")
var player_scene := preload("res://scenes/player.tscn")
var is_paused: bool = false:
	set(value):
		is_paused = value
		var new_process_mode := PROCESS_MODE_DISABLED if value else PROCESS_MODE_INHERIT
		players.process_mode = new_process_mode
		projectiles.process_mode = new_process_mode
		hud.process_mode = new_process_mode
		rockets.process_mode = new_process_mode
		if value:
			pause_screen.show()
		else:
			pause_screen.hide()

func _ready():
	var new_player := player_scene.instantiate() as Player
	hud.max_energy = new_player.max_energy
	hud.energy = new_player.energy
	players.add_child(new_player)
	
	for player in players.get_children():
		player.connect("rocket_fired", _on_player_rocket_fired)
		player.connect("death", game_over)
	
	for projectile in projectiles.get_children():
		projectile.connect("exploded", _on_projectile_exploded)
	
func _process(_delta):
	if Input.is_action_pressed("Reset") and OS.is_debug_build():
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("Open Pause Menu"):
		is_paused = !is_paused
	
	# Update energy
	hud.energy = players.get_children()[0].energy
	
	if randf() < asteroid_spawn_probability and projectiles.get_child_count() < max_projectile_count:
		# Spawn randomly on a circle around the player
		var data = get_random_spawn_data()
		var size = randi() % Asteroid.AsteroidSize.size() as Asteroid.AsteroidSize
		spawn_asteroid(data.pos, size, data.rot)
	
	if randf() < broken_craft_spawn_probability and projectiles.get_child_count() < max_projectile_count:
		# Spawn randomly on a circle around the player
		var data = get_random_spawn_data()

		spawn_broken_craft(data.pos, data.rot)

func get_random_spawn_data():
	# Randomly spawn asteroids outside the viewport
	var screen_size := get_viewport_rect().size
	
	var biggest_axis := 0.0
	if screen_size.x > screen_size.y:
		biggest_axis = screen_size.x
	else:
		biggest_axis = screen_size.y
		
	var circle_position = randf_range(0, 2 * PI)
	var player_relative_vector = Vector2(0, biggest_axis + 50).rotated(circle_position)
	var world_pos: Vector2 = (players.get_children()[0] as Player).global_position + player_relative_vector
	# Make asteroid point vaguely towards player
	var starting_rotation = world_pos.angle_to(world_pos - player_relative_vector)
	starting_rotation += randf_range(-1, 1)
	return { "pos": world_pos, "rot": starting_rotation }

func _on_player_rocket_fired(rocket):
	rockets.add_child(rocket)

func _on_projectile_exploded(projectile: Projectile, player: Player):
	# Increase score
	if player:
		player.score += projectile.points
		hud.score = player.score
	
	# Destroy asteroid and spawn more
	if projectile is Asteroid:
		if projectile.size == Asteroid.AsteroidSize.TINY:
			# Don't make new asteroids once the smallest ones are destroyed
			return
			
		var new_size := Asteroid.AsteroidSize.MEDIUM
		
		match projectile.size:
			Asteroid.AsteroidSize.MEDIUM:
				new_size = Asteroid.AsteroidSize.SMALL
			Asteroid.AsteroidSize.SMALL:
				new_size = Asteroid.AsteroidSize.TINY
		
		for i in 2:
			spawn_asteroid(projectile.global_position, new_size, 0)
	

func spawn_asteroid(asteroid_position: Vector2, size: Asteroid.AsteroidSize, asteroid_rotation: float):
	var new_asteroid := asteroid_scene.instantiate()
	new_asteroid.size = size
	new_asteroid.global_position = asteroid_position
	if asteroid_rotation:
		new_asteroid.initial_rotation = asteroid_rotation
	new_asteroid.connect("exploded", _on_projectile_exploded)

	projectiles.call_deferred("add_child", new_asteroid)

func spawn_broken_craft(craft_position: Vector2, craft_rotation: float):
	var new_projectile := broken_craft_scene.instantiate()
	new_projectile.global_position = craft_position
	if craft_rotation:
		new_projectile.initial_rotation = craft_rotation
	new_projectile.connect("exploded", _on_projectile_exploded)

	projectiles.call_deferred("add_child", new_projectile)
	
func game_over():
	SceneTransition.change_scene("res://scenes/game_over.tscn")


func _on_pause_screen_resume():
	is_paused = false


func _on_pause_screen_restart():
	get_tree().reload_current_scene()
