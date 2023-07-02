extends Resource

class_name PlayerData

@export var inventory_data : InventoryData = preload("res://inventory/inventory.tres")
@export var chest_inventory_datas : Dictionary
@export var player_pos : Vector2 = Vector2(118, 947)
@export var time : float = 12
@export var day : int 
@export var coins = 0

@export var master_volume = 0
@export var music_volume = 0
@export var sfx_volume = 0



func update_data():
	print(chest_inventory_datas)
	global.coins = coins
	global.day = day
	if global.chest_inventory_datas == {}:
		global.chest_inventory_datas = chest_inventory_datas
func update_audio():
	if master_volume == -30:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume)
	if music_volume == -30:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)
	if sfx_volume == -30:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_volume)
	
