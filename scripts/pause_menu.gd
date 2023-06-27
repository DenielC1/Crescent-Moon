extends Node2D

@onready var UI = $"../../UI"
@onready var game = $"../.."
@onready var canvas_layer = $CanvasLayer

@onready var resume_button = $CanvasLayer/Options/VBoxContainer/Resume_Button
@onready var setting_button = $CanvasLayer/Options/VBoxContainer/Setting_Button
@onready var quit_button = $CanvasLayer/Options/VBoxContainer/Quit_Button

@onready var options = $CanvasLayer/Options
@onready var settings = $CanvasLayer/Settings

var using_settings : bool = false

func _process(_delta):
	if game.is_escaped and not using_settings:
		options.show()
		
func _input(event):
	if event.is_action_pressed("escape") and not using_settings:
		resume_game()
	if event.is_action_pressed("escape") and using_settings:
		using_settings = false
		settings.hide()
		
func resume_game(): 
	get_parent().get_tree().paused = false
	UI.show()
	settings.hide()
	options.hide()
	game.modulate = Color(1, 1, 1)
	

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
