class_name Projectile extends Area2D

signal exploded(projectile: Projectile, player: Player)

@export_group("Values")
@export_subgroup("Physics")
@export var min_speed := 60
@export var max_speed := 120
@export var min_rotation := 3.0
@export var max_rotation := 7.0
@export var despawn_radius := 2000
@export var max_collision_relative_speed := 0.0
@export var invincibility_period := .8
@export var initial_rotation = randf_range(0, 2 * PI)
@export var max_lifetime = 0.0
@export_subgroup("Rewards")
@export var points := 0.0

@export_group("Display")
@export var show_damage_numbers := true

@export_group("Nodes")
@export var sprite: Sprite2D
@export var collision_shape: CollisionShape2D
@export_subgroup("Explosion Nodes")
@export var explosion_sprite: AnimatedSprite2D
@export var explosion_audio: AudioStreamPlayer2D

@export_group("Ownership")
@export var creator: Player

@export_group("Sizing")
@export var enable_sizing: bool
@export var size_index: int
@export var speed_scales_array: Array[float]
@export var points_array: Array[float]
@export var size_scales_array: Array[float]

var movement := Vector2(0.0, -1.0)
var is_exploding := false
var created_at := Time.get_ticks_msec()

var speed := 0.0

func _ready():
	rotation = initial_rotation
	explosion_sprite.hide()
	connect("body_entered", _on_body_entered)
	
	if enable_sizing:
		assert (typeof(size_index) == TYPE_INT, "Size index is required if sizing is enabled")
		assert ((len(speed_scales_array) == len(points_array)) and (len(speed_scales_array) == len(size_scales_array)), "Sizing arrays are not the same size")
		assert (size_index < len(speed_scales_array) and size_index >= 0, "Invalid size index")
		speed = randf_range(min_speed * speed_scales_array[size_index], max_speed * speed_scales_array[size_index])
		points = points_array[size_index]
		scale = Vector2(size_scales_array[size_index], size_scales_array[size_index])

func _process(_delta):
	var players := get_tree().get_nodes_in_group("Players")
	
	# Calculate distance to players, and automatically despawn if too far away
	for player in players:
		if global_position.distance_to(player.global_position) > despawn_radius:
			queue_free()
	
	if max_lifetime > 0.0 and Time.get_ticks_msec() - created_at > max_lifetime * 1000:
		explode(null)

func _physics_process(delta):
	global_position += movement.rotated(rotation) * speed * delta

func explode(player: Player):
	if is_exploding or Time.get_ticks_msec() - created_at < invincibility_period * 1000:
		return
	
	if show_damage_numbers:
		# Calculate position right above asteroid
		var damage_position = global_position + Vector2(0, -40)
		# Add damage numbers
		DamageNumbers.display_number(points, damage_position, false, 2.0, "#2B2")
		
	# Draw explosion over new asteroids
	z_index = 10
	if explosion_audio:
		explosion_audio.play()

	is_exploding = true
	emit_signal("exploded", self, player)
	sprite.hide()
	if explosion_sprite:
		explosion_sprite.show()
		explosion_sprite.play("default")
		await explosion_sprite.animation_finished
	queue_free()

func _on_body_entered(body):
	print(body)
	if is_exploding or Time.get_ticks_msec() - created_at < invincibility_period * 1000:
		return
	if body is Player:
		explode(body)
		body.collide(self)
	if body is Projectile:
		explode(null)
