extends Control

signal resume
signal restart

func _on_resume_pressed():
	emit_signal("resume")


func _on_quit_pressed():
	emit_signal("restart")
