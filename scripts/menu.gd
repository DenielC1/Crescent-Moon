extends CanvasLayer

var save_file_path = "user://save/"
var save_file_name = "PlayerSave.tres"

var player_data : PlayerData = PlayerData.new()

@onready var setting_menu = $Setting_menu

@onready var game = preload("res://scenes/game.tscn")

@onready var master = $Setting_menu/PanelContainer/VBoxContainer/Master
@onready var music = $Setting_menu/PanelContainer/VBoxContainer/Music
@onready var sfx = $Setting_menu/PanelContainer/VBoxContainer/SFX

func _ready():
	verify_save_directory(save_file_path)
	load_data()
	
func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)
	if not FileAccess.file_exists("user://save/PlayerSave.tres"):
		ResourceSaver.save(player_data, save_file_path + save_file_name)
func load_data():
	print("DATA LOADED")
	player_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	player_data.update_audio()
	
func save_data():
	print("DATA SAVED")
	ResourceSaver.save(player_data, save_file_path + save_file_name)
	
func _process(_delta):
	if global.data_loaded:
		if master.value_changed:
			player_data.master_volume = master.value
		if music.value_changed:
			player_data.music_volume = music.value
		if sfx.value_changed:
			player_data.sfx_volume = sfx.value
		player_data.update_audio()
		
func _on_quit_pressed():
	save_data()
	get_tree().quit()


func _on_settings_pressed():
	setting_menu.show()



func _on_return_button_pressed():
	setting_menu.hide()


func _on_play_pressed():
	save_data()
	get_tree().change_scene_to_packed(game)
