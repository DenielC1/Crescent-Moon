extends Node2D

@onready var player = $TileMap/player
@onready var hotbar_grid = $UI/Hotbar/hotbar_grid
@onready var inventory_grid = $UI/Inventory/inventory_grid
@onready var label = $UI/Label

const Slot = preload("res://item/slot.tscn")

func _ready():
	load_inventory()
	
func load_inventory():
	for child in hotbar_grid.get_children():
		child.queue_free()
	for child in inventory_grid.get_children():
		child.queue_free()
		
	var inventory = player.inventory_data
	var index = 0
	while index <5:
		var slot_data = inventory.slot_datas[index]
		var slot = Slot.instantiate()
		if slot_data != null:
			slot.import_item_data(slot_data)
		hotbar_grid.add_child(slot)
		index += 1
	while index >= 5 and index < 20:
		var slot_data = inventory.slot_datas[index]
		var slot = Slot.instantiate()
		if slot_data != null:
			slot.import_item_data(slot_data)
		inventory_grid.add_child(slot)
		index += 1
		
func _physics_process(_delta):
	select_slot()
	if player.tabbed:
		label.text = "tabbed"
		$UI/Inventory.show()
	else:
		label.text = "not tabbed"
		$UI/Inventory.hide()
		
func select_slot():
	if player.key >= 0 and player.key <= 4:
		if player.key != player.prev_key:
			hotbar_grid.get_child(player.key).modulate = Color(1, 1, 1, 0.27450981736183)
			hotbar_grid.get_child(player.prev_key).modulate = Color(1, 1, 1)
			player.prev_key = player.key
		if !player.equipped:
			hotbar_grid.get_child(player.prev_key).modulate = Color(1, 1, 1)
			player.prev_key = -1
