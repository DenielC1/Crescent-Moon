extends Node2D

@onready var player = $TileMap/player
@onready var hotbar_grid = $UI/Hotbar/hotbar_grid
@onready var inventory_grid = $UI/Inventory/inventory_grid
@onready var label = $UI/Label
@onready var dropped_items = $TileMap/DroppedItems

const Slot = preload("res://item/slot.tscn")
const ItemDrop = preload("res://item_drop.tscn")
var temp = -1
var is_escaped : bool = false
var rng = RandomNumberGenerator.new() 
var item_position_x : float
var item_position_y : float

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
		hotbar_grid.get_child(player.key).modulate = Color(1, .5, 1, 0.27450981736183)
		if temp != -1 and temp != player.key:
			hotbar_grid.get_child(temp).modulate = Color(1, 1, 1, 1)
		temp = player.key
		if !player.equipped:
			hotbar_grid.get_child(temp).modulate = Color(1, 1, 1)
	if player.tabbed: 
		hotbar_grid.get_child(temp).modulate = Color(1, 1, 1)
		
func _input(event):
	if event.is_action_pressed("escape"):
		is_escaped = not is_escaped
		print(is_escaped)
		if is_escaped:
			modulate = Color(0.22745098173618, 0.22745098173618, 0.22745098173618)
			get_tree().paused = true
			$UI.hide()
		
func create_drop_items(drop_count : int, item_position : Vector2, item_data : ItemData, quantity : int):
	while drop_count > 0:
		var item = ItemDrop.instantiate()
		var item_quantity = item.get_child(4)
		item.item_data = item_data
		item_quantity.set_deferred("text", quantity)
		item.set_deferred("position", generate_item_position(item_position))
		dropped_items.call_deferred("add_child", item)
		drop_count -= 1
		
func generate_item_position(item_position : Vector2):
	rng.randomize()
	var chance = rng.randf()
	if chance >= 0.5:
		item_position_x = rng.randf_range(item_position.x-20, item_position.x-10)
	else:
		item_position_x = rng.randf_range(item_position.x+10, item_position.x+20)
	rng.randomize()
	chance = rng.randf()
	if chance > 0.5:
		item_position_y = rng.randf_range(item_position.y+10, item_position.y+20)
	else:
		item_position_y = rng.randf_range(item_position.y-20, item_position.y-10)
	return Vector2(item_position_x, item_position_y)
	
func on_item_pick_up(item_data : ItemData, quantity : int):
	$UI.pick_up_item(item_data, quantity)
