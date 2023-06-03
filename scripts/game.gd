extends Node2D

@onready var player = $TileMap/player
@onready var hotbar_grid = $UI/PanelContainer/hotbar_grid

const Slot = preload("res://item/slot.tscn")

func _ready():
	load_hotbar()
	
func load_hotbar():
	var inventory = player.inventory_data
	for slot_data in inventory.slot_datas:
		var slot = Slot.instantiate()
		if slot_data != null:
			slot.import_item_data(slot_data)
		hotbar_grid.add_child(slot)
		
func _physics_process(_delta):
	select_slot()
	
func select_slot():
	if player.key >= 0 and player.key <= 4:
		if player.key != player.prev_key:
			hotbar_grid.get_child(player.key).modulate = Color(1, 1, 1, 0.27450981736183)
			hotbar_grid.get_child(player.prev_key).modulate = Color(1, 1, 1)
			player.prev_key = player.key
