extends Area2D

enum AsteroidSize{LARGE, MEDIUM, SMALL, TINY}
@export var size := AsteroidSize.LARGE
@export var min_speed := 60
@export var max_speed := 120
@export var min_rotation := 3.0
@export var max_rotation := 7.0

var movement := Vector2(0.0, -1.0)

var speed := 0.0

func _ready():
	rotation = randf_range(0, 2 * PI)
	
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(min_speed, max_speed)
		AsteroidSize.MEDIUM:
			speed = randf_range(min_speed * 2, max_speed * 2)
		AsteroidSize.SMALL:
			speed = randf_range(min_speed * 4, max_speed * 4)
		AsteroidSize.TINY:
			speed = randf_range(min_speed * 8, max_speed * 8)

func _physics_process(delta):
	global_position += movement.rotated(rotation) * speed * delta
