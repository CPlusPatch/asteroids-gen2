extends Node2D

@onready var StarfieldBack: GPUParticles2D = $StarfieldBack

func _ready():
	var screen_size = get_viewport_rect().size
	
	StarfieldBack.material.set
