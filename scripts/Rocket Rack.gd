extends AnimatedSprite2D

func _ready():
	autoplay = "0"


func _on_animation_finished():
	if animation == "6":
		play("0")
