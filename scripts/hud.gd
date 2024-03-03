class_name HUD extends Control

@export var max_energy: float = 200.0:
	set(value):
		($EnergyContainer/EnergyBar).init_energy(value)

@onready var score = $ScoreContainer/Score:
	set(value):
		score.text = "%04d" % value
@onready var energy = $EnergyContainer/EnergyBar:
	set(value):
		energy.energy = value
