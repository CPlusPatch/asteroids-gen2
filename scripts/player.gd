extends CharacterBody2D

signal rocket_fired(rocket)
signal y_out_of_bounds(side: int)
signal x_out_of_bounds(side: int)

@export var acceleration := 10.0
@export var max_speed := 550.0
@export var brake_speed := 3.0
@export var rotation_speed := 250.0
@export var firing_cooldown := 0.2
@export var initial_ammo := 6
@export var rocket_rack_capacity := 6

@onready var firing_spots := $"Rocket Firing Spots"
@onready var rocket_rack_sprites := $"Body/Rocket Rack"

var rocket_scene := preload("res://scenes/rocket.tscn")

var shoot_cooldown := false

# Index of current rocket in firing rack
var rocket_rack_index := 0

func _process(delta):
	if Input.is_action_pressed("Fire"):
		if !shoot_cooldown:
			fire_rocket()
			
			shoot_cooldown = true
			await get_tree().create_timer(firing_cooldown).timeout
			shoot_cooldown = false

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
	
	var screen_size = get_viewport_rect().size
	
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
	
	emit_signal("rocket_fired", new_rocket)
	
	# Emit random rocket fire sound
	var audio: AudioStreamPlayer = $"Firing Sounds".get_children().pick_random()
	
	audio.play()
