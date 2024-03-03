extends Area2D

@export var speed := 1000.0
@export var random_rotation_difference_max := 4.0

# Always go forward at fixed speed
var movement_vector := Vector2(0, -1)

func _ready():
	# Apply random rotation differences for variety
	rotation += deg_to_rad(randf_range(-random_rotation_difference_max, random_rotation_difference_max))

func _physics_process(delta):
	# No move_and_slide since this is a simple sprite
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var screen_size = get_viewport_rect().size
	
	# Check if rocket is out of bounds
	#if global_position.y < 0:
		#global_position.y = screen_size.y
	#elif global_position.y > screen_size.y:
		#global_position.y = 0
		#
	#if global_position.x < 0:
		#global_position.x = screen_size.x
	#elif global_position.x > screen_size.x:
		#global_position.x = 0


func _on_timer_timeout():
	# Stop movement
	movement_vector = Vector2(0.0, 0.0)
	
	# Play explosion sound
	($"ExplosionAudio" as AudioStreamPlayer2D).play()
	
	# Explode
	var animated_sprite: AnimatedSprite2D = $"AnimatedSprite2D"
	animated_sprite.play("explosion")
	
	# Wait for the explosion animation to finish
	await get_tree().create_timer(1.4).timeout
	queue_free()
