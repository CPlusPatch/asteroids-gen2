extends Label

@export var speed := 1.0
@export var progress := 0.0

var text_to_type := ""

func _ready():
	text_to_type = text
	text = ""

var time_since_last_character := Time.get_ticks_msec()

func _process(_delta):
	if Time.get_ticks_msec() - time_since_last_character < speed * 1000:
		return
		
	var progress_per_character = 1.0 / text_to_type.length()
	
	text = text_to_type.left(progress_to_character(progress))
	progress += progress_per_character
	time_since_last_character = Time.get_ticks_msec()

func progress_to_character(_progress: float):
	return text_to_type.length() * progress
	
