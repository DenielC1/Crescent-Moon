extends CenterContainer

@onready var master = $PanelContainer/VBoxContainer/Master
@onready var music = $PanelContainer/VBoxContainer/Music
@onready var sfx = $PanelContainer/VBoxContainer/SFX

func _process(_delta):
	if not global.data_loaded:
		master.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
		music.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
		sfx.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
		global.data_loaded = true
