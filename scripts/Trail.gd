extends Line2D

var target: Node
var point := Vector2(0.0, 0.0)
@export var target_path: NodePath
@export var position_node: Node2D
@export var trail_length := 25.0

func _ready():
	target = get_node(target_path)
	clear_points()

func _process(_delta):
	global_position = Vector2(0.0, 0.0)
	global_rotation = 0
	point = position_node.global_position

	add_point(point)
	
	while get_point_count() > trail_length:
		remove_point(0)

func _on_player_x_out_of_bounds(side):
	var last_point := points[-1]
	
	# Went from left to right
	if side == -1:
		add_point(Vector2(-100000, last_point.y))
		add_point(Vector2(-100000, -100000))
		add_point(Vector2(100000, -100000))
		add_point(Vector2(100000, last_point.y))
	# Right to left
	elif side == 1:
		add_point(Vector2(100000, last_point.y))
		add_point(Vector2(100000, -100000))
		add_point(Vector2(-100000, -100000))
		add_point(Vector2(-100000, last_point.y))


func _on_player_y_out_of_bounds(side):
	var last_point := points[-1]
	
	# Went from top to bottom
	if side == -1:
		add_point(Vector2(last_point.x, -100000))
		add_point(Vector2(-100000, -100000))
		add_point(Vector2(-100000, 100000))
		add_point(Vector2(last_point.x, 100000))
	# Bottom to top
	elif side == 1:
		add_point(Vector2(last_point.x, 100000))
		add_point(Vector2(100000, 100000))
		add_point(Vector2(100000, -100000))
		add_point(Vector2(last_point.x, -100000))
