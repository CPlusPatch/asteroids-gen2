class_name BrokenCraft extends Projectile

func _ready():
	super._ready()
	sprite.rotate(randf_range(0, 2*PI))
