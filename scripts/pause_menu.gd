extends Node2D

@onready var UI = $"../UI"
@onready var game = $".."
@onready var canvas_layer = $CanvasLayer
@onready var background = $CanvasLayer/Background

@onready var options = $CanvasLayer/Options
@onready var settings = $CanvasLayer/Settings

@onready var master = $CanvasLayer/Settings/PanelContainer/VBoxContainer/Master
@onready var music = $CanvasLayer/Settings/PanelContainer/VBoxContainer/Music
@onready var sfx = $CanvasLayer/Settings/PanelContainer/VBoxContainer/SFX

var using_settings : bool = false

func _process(_delta):
	if global.game_paused:
		canvas_layer.show()
		background.show()
	if game.is_escaped and not using_settings:
		options.show()
	if master.value_changed:
		if master.value == -20:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		else:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master.value)
	if music.value_changed:
		if music.value == -20:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
		else:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), master.value)
	if sfx.value_changed:
		if sfx.value == -20:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
		else:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), master.value)
			
func _input(event):
	if event.is_action_pressed("escape") and not using_settings:
		resume_game()
	if event.is_action_pressed("escape") and using_settings:
		using_settings = false
		settings.hide()
	
func resume_game(): 
	canvas_layer.hide()
	background.hide()
	get_parent().get_tree().paused = false
	

func _on_resume_pressed():
	game.is_escaped = not game.is_escaped
	resume_game()
	
func _on_setting_button_pressed():
	using_settings = true
	options.hide()
	settings.show()

func _on_quit_pressed():
	
	get_tree().quit()

func _on_return_button_pressed():
	using_settings = false
	settings.hide()
