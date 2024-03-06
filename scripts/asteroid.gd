class_name Asteroid extends Projectile

enum AsteroidSize{TINY, SMALL, MEDIUM, LARGE}
@export var size := AsteroidSize.LARGE

func _ready():
	size_index = size
	super._ready()
