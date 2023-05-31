extends Node2D

@onready var player = $TileMap/player
@onready var inventory_interface = $GUI/InventoryInterface


func _ready():
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	
	for child in inventory_interface.item_grid.get_children():
		if child.get_index() < 15:
			child.visible = not child.visible
			
func toggle_inventory_interface():
	for child in inventory_interface.item_grid.get_children():
		if child.get_index() < 15:
			child.visible = not child.visible
