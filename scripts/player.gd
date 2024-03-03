class_name Player extends CharacterBody2D

signal rocket_fired(rocket)
signal death

@export var acceleration := 10.0
@export var max_speed := 550.0
@export var brake_speed := 3.0
@export var rotation_speed := 250.0
@export var firing_cooldown := 0.2
@export var initial_ammo := 6
@export var rocket_rack_capacity := 6
@export var score := .0
# Corresponds to a camera scale of 2**zoom
@export var min_zoom := -1
@export var max_zoom := 2
@export var energy := 200.0
@export var max_energy := 200.0
@export var energy_regen_rate := 2

@onready var firing_spots := $"Rocket Firing Spots"
@onready var rocket_rack_sprites := $"Body/Rocket Rack"
@onready var camera := $Camera2D as Camera2D
@onready var zoom: float:
	get:
		return camera.zoom.x
	set(value):
		camera.zoom.x = value
		camera.zoom.y = value

var rocket_scene := preload("res://scenes/rocket.tscn")

var shoot_cooldown := false
var current_zoom := 0
var zooming_in := false
var zooming_out := false

# Index of current rocket in firing rack
var rocket_rack_index := 0

func _process(delta):
	if Input.is_action_pressed("Fire"):
		if !shoot_cooldown:
			fire_rocket()
			
			shoot_cooldown = true
			await get_tree().create_timer(firing_cooldown).timeout
			shoot_cooldown = false
	if Input.is_action_just_pressed("Zoom In"):
		current_zoom += 1
		zooming_in = true
		zooming_out = false
		# update_zoom()
	elif Input.is_action_just_pressed("Zoom Out"):
		current_zoom -= 1
		zooming_in = false
		zooming_out = true
		# update_zoom()
	
	current_zoom = clamp(current_zoom, min_zoom, max_zoom)
	
	if energy < max_energy:
		energy += energy_regen_rate * delta
	energy = clamp(energy, 0, max_energy)
	
	if zooming_in or zooming_out:
		zoom = lerp(zoom, pow(2, current_zoom), delta * 2.0)

func update_zoom():
	current_zoom = clamp(current_zoom, min_zoom, max_zoom)

	assert(camera.zoom.x == camera.zoom.y, "Player Camera2D x and y zoom must be the same!")
	var camera_zoom = log(camera.zoom.x) / log(2) # Log2
	
	if current_zoom == camera_zoom:
		return
	
	camera.zoom.x = pow(2, current_zoom)
	camera.zoom.y = pow(2, current_zoom)

func _physics_process(delta):
	var input_vector := Vector2(0, Input.get_axis("Forward", "Backward"))
	
	velocity += input_vector.rotated(rotation) * acceleration
	# Cap the speed
	velocity = velocity.limit_length(max_speed)
	
	# Rotation
	if Input.is_action_pressed("Rotate Right"):
		rotate(deg_to_rad(rotation_speed * delta))
	if Input.is_action_pressed("Rotate Left"):
		rotate(deg_to_rad(-1 * rotation_speed * delta))
		
	 # Thruster sound
	if Input.is_action_just_pressed("Rotate Left") or Input.is_action_just_pressed("Rotate Right"):
		play_thruster_sound()
	
	# Automatic brake
	# TODO: Add gamemode with automatic brake disabled
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, brake_speed)
	move_and_slide()
	
	# var screen_size = get_viewport_rect().size
	
	# Check if player is out of bounds
	#if global_position.y < 0:
		#global_position.y = screen_size.y
		#emit_signal("y_out_of_bounds", -1)
	#elif global_position.y > screen_size.y:
		#global_position.y = 0
		#emit_signal("y_out_of_bounds", 1)
		#
	#if global_position.x < 0:
		#global_position.x = screen_size.x
		#emit_signal("x_out_of_bounds", -1)
	#elif global_position.x > screen_size.x:
		#global_position.x = 0
		#emit_signal("x_out_of_bounds", 1)

func play_thruster_sound():
	# Check if sound is already playing
	var thruster_sounds = $"Thruster Sounds".get_children() as Array[AudioStreamPlayer]
	
	# Stop all currently playing thruster sounds
	for thruster in thruster_sounds:
		thruster.stop()
	
	# Emit thruster sound
	var audio = thruster_sounds.pick_random()
	
	audio.play()

func fire_rocket():
	# Instantiate new rocket sprite
	var new_rocket := rocket_scene.instantiate()
	
	var selected_firing_spot := firing_spots.get_children()[rocket_rack_index]
	
	rocket_rack_index += 1
	rocket_rack_sprites.play(str(rocket_rack_index))
	
	if rocket_rack_index >= rocket_rack_capacity:
		rocket_rack_index = 0
	
	new_rocket.global_position = selected_firing_spot.global_position
	new_rocket.rotation = rotation
	new_rocket.player = self
	
	emit_signal("rocket_fired", new_rocket)
	
	# Emit random rocket fire sound
	var audio: AudioStreamPlayer = $"Firing Sounds".get_children().pick_random()
	
	audio.play()
	
func collide(body):
	if body is Asteroid:
		energy -= body.energy_cost
		if energy < 0:
			die()

func die():
	emit_signal("death")
	process_mode = Node.PROCESS_MODE_DISABLED
