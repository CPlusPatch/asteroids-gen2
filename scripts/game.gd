extends Node2D

@export var spawn_probability := 0.05
@export var max_asteroid_count := 100

@onready var rockets := $Rockets
@onready var players := $Players
@onready var asteroids := $Asteroids
@onready var hud := $UI/HUD as HUD

var asteroid_scene := preload("res://scenes/asteroid.tscn")
var player_scene := preload("res://scenes/player.tscn")

func _ready():
	var new_player := player_scene.instantiate() as Player
	hud.max_energy = new_player.max_energy
	hud.energy = new_player.energy
	players.add_child(new_player)
	
	for player in players.get_children():
		player.connect("rocket_fired", _on_player_rocket_fired)
		player.connect("death", game_over)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
	
func _process(_delta):
	if Input.is_action_pressed("Reset") and OS.is_debug_build():
		get_tree().reload_current_scene()
	
	# Update energy
	hud.energy = players.get_children()[0].energy
	
	# Randomly spawn asteroids outside the viewport
	var screen_size := get_viewport_rect().size
	
	var biggest_axis := 0.0
	
	if screen_size.x > screen_size.y:
		biggest_axis = screen_size.x
	else:
		biggest_axis = screen_size.y
	
	if randf() < spawn_probability and asteroids.get_child_count() < max_asteroid_count:
		# Spawn randomly on a circle around the player
		var circle_position = randf_range(0, 2 * PI)
		var player_relative_vector = Vector2(0, biggest_axis + 50).rotated(circle_position)
		var world_pos: Vector2 = (players.get_children()[0] as Player).global_position + player_relative_vector
		# Make asteroid point vaguely towards player
		var starting_rotation = world_pos.angle_to(world_pos - player_relative_vector)
		starting_rotation += randf_range(-1, 1)
		var size = randi() % Asteroid.AsteroidSize.size() as Asteroid.AsteroidSize
		spawn_asteroid(world_pos, size, starting_rotation)
	
func _on_player_rocket_fired(rocket):
	rockets.add_child(rocket)

func _on_asteroid_exploded(asteroid: Asteroid, player: Player):
	# Increase score
	if player:
		player.score += asteroid.points
		hud.score = player.score
	
	# Destroy asteroid and spawn more
	if asteroid.size == Asteroid.AsteroidSize.TINY:
		# Don't make new asteroids once the smallest ones are destroyed
		return
		
	var new_size := Asteroid.AsteroidSize.MEDIUM
	
	match asteroid.size:
		Asteroid.AsteroidSize.MEDIUM:
			new_size = Asteroid.AsteroidSize.SMALL
		Asteroid.AsteroidSize.SMALL:
			new_size = Asteroid.AsteroidSize.TINY
	
	for i in 2:
		spawn_asteroid(asteroid.global_position, new_size, 0)
	

func spawn_asteroid(asteroid_position: Vector2, size: Asteroid.AsteroidSize, asteroid_rotation: float):
	var new_asteroid := asteroid_scene.instantiate()
	new_asteroid.size = size
	new_asteroid.global_position = asteroid_position
	if asteroid_rotation:
		new_asteroid.initial_rotation = asteroid_rotation
	new_asteroid.connect("exploded", _on_asteroid_exploded)

	asteroids.call_deferred("add_child", new_asteroid)
	
func game_over():
	SceneTransition.change_scene("res://scenes/game_over.tscn")
