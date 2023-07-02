extends Node2D

@onready var wind = $Wind
@onready var birds = $Birds
@onready var music = $Music




func _on_birds_finished():
	birds.play()

func _on_wind_finished():
	wind.play()

func _on_music_finished():
	music.play()
