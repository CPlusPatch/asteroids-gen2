class_name Asteroid extends Area2D

signal exploded(asteroid: Asteroid, player: Player)

enum AsteroidSize{LARGE, MEDIUM, SMALL, TINY}
@export var size := AsteroidSize.LARGE
@export var min_speed := 60
@export var max_speed := 120
@export var min_rotation := 3.0
@export var max_rotation := 7.0
@export var despawn_radius := 2000
@export var max_collision_relative_speed := 0.0
@export var invincibility_period := .8
@export var initial_rotation = randf_range(0, 2 * PI)

var movement := Vector2(0.0, -1.0)
var is_exploding := false
var created_at := Time.get_ticks_msec()

var speed := 0.0
var points: int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 20
			AsteroidSize.MEDIUM:
				return 40
			AsteroidSize.SMALL:
				return 80
			AsteroidSize.TINY:
				return 160
			_:
				return 0

@onready var sprite = $Sprite2D

func _ready():
	rotation = initial_rotation
	
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(min_speed, max_speed)
			# TODO: Change texture
			scale = Vector2(3, 3)
		AsteroidSize.MEDIUM:
			speed = randf_range(min_speed * 2, max_speed * 2)
			scale = Vector2(2, 2)
			# TODO: Change texture
		AsteroidSize.SMALL:
			speed = randf_range(min_speed * 4, max_speed * 4)
			# TODO: Change texture
			scale = Vector2(1.5, 1.5)
		AsteroidSize.TINY:
			speed = randf_range(min_speed * 8, max_speed * 8)
			# TODO: Change texture
			scale = Vector2(1, 1)

func _process(_delta):
	var players := get_tree().get_nodes_in_group("Players")
	
	# Calculate distance to players, and automatically despawn if too far away
	for player in players:
		if global_position.distance_to(player.global_position) > despawn_radius:
			queue_free()

func _physics_process(delta):
	global_position += movement.rotated(rotation) * speed * delta

func explode(player: Player):
	if is_exploding or Time.get_ticks_msec() - created_at < invincibility_period * 1000:
		return
		
	# Draw explosion over new asteroids
	z_index = 10
	$ExplosionAudio.play()

	is_exploding = true
	emit_signal("exploded", self, player)
	sprite.hide()
	($ExplosionSprite as AnimatedSprite2D).show()
	($ExplosionSprite as AnimatedSprite2D).play("default")
	await get_tree().create_timer(1.4).timeout
	queue_free()


func _on_body_entered(body):
	if is_exploding:
		return
	if body is Player:
		# Check relative speed, explode if too high
		# if (body.velocity - (movement.rotated(rotation) * speed)).length() > max_collision_relative_speed:
		explode(body)
		body.collide(self)
	if body is Asteroid:
		explode(null)
