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

@onready var player_data = get_parent().player_data

var using_settings : bool = false

func _process(_delta):
	if global.data_loaded:
		player_data.chest_inventory_datas = global.chest_inventory_datas
		player_data.day = global.day
		player_data.time = global.actual_time
		player_data.inventory_data = get_parent().player.inventory_data
		player_data.player_pos = get_parent().player.position
		player_data.coins = global.coins
		if master.value_changed:
			player_data.master_volume = master.value
		if music.value_changed:
			player_data.music_volume = music.value
		if sfx.value_changed:
			player_data.sfx_volume = sfx.value
		player_data.update_audio()
	if global.game_paused:
		canvas_layer.show()
		background.show()
	if game.is_escaped and not using_settings:
		options.show()

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
	
func _on_return_button_pressed():
	using_settings = false
	settings.hide()


func _on_quit_button_pressed():
	var save_file_path = get_parent().save_file_path
	var save_file_name =  get_parent().save_file_name
	ResourceSaver.save(player_data, save_file_path + save_file_name)
	get_tree().quit()
