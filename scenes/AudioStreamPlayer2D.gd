extends AudioStreamPlayer2D

@onready var AudioSteam = self

func _on_finished():
	print("ed")
	AudioSteam.play()
