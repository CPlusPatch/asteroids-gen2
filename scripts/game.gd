extends Node2D

@onready var rockets := $Rockets
@onready var player := $Player

func _ready():
	player.connect("rocket_fired", _on_player_rocket_fired)
	
func _process(delta):
	if Input.is_action_pressed("Reset") and OS.is_debug_build():
		get_tree().reload_current_scene()
	
func _on_player_rocket_fired(rocket):
	rockets.add_child(rocket)
