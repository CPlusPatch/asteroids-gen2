extends Control

@onready var score = $ScoreContainer/Score:
	set(value):
		score.text = "%04d" % value
