extends Node2D

@onready var player = $TileMap/player
@onready var hotbar_grid = $UI/Hotbar/hotbar_grid
@onready var inventory_grid = $UI/CenterContainer/Inventory/inventory_grid
@onready var dropped_items = $TileMap/DroppedItems
@onready var selection = $UI/Hotbar/Selection
@onready var pick_up = $Audio/Pick_up
@onready var tile_map = $TileMap

const Slot = preload("res://item/slot/slot.tscn")
const ItemDrop = preload("res://item/item_drop/item_drop.tscn")

var set_item_id = 0
var temp : int = -1
var is_escaped : bool = false 

var rng = RandomNumberGenerator.new() 
var item_position_x : float
var item_position_y : float

var is_inventory_full : bool = false

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
	if global.is_selling_goods:
		player.using_inventory = true
	if player.using_inventory:
		$UI/CenterContainer/Inventory.show()
	else:
		$UI/CenterContainer/Inventory.hide()

func select_slot():
	if player.index != -1:
		selection.offset.x = 21 * player.index
		selection.show()
		if temp != player.index:
			selection.hide()
		temp = player.index
	else:
		selection.hide()
		
func _input(event):
	if event.is_action_pressed("escape") and not global.is_selling_goods and not player.using_inventory:
		is_escaped = not is_escaped
		if is_escaped:
			modulate = Color(0.22745098173618, 0.22745098173618, 0.22745098173618)
			get_tree().paused = true
	elif event.is_action_pressed("escape") and player.using_inventory:
		player.using_inventory = false
func create_drop_items(drop_count : int, item_position : Vector2, item_data : ItemData, quantity : int, random_pos : bool):
	while drop_count > 0:
		var item = ItemDrop.instantiate()
		var item_quantity = item.get_child(4)
		item.item_data = item_data
		item.item_id = set_item_id
		item_quantity.set_deferred("text", quantity)
		if random_pos:
			item.set_deferred("position", generate_item_position(item_position))
		else: 
			item.set_deferred("position", item_position)
		dropped_items.call_deferred("add_child", item)
		drop_count -= 1
		set_item_id += 1
		
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

func use_item_slot(slot_data : SlotData):
	slot_data.quantity -= 1
	if slot_data.quantity <= 0:
		player.inventory_data.slot_datas[player.index] = null
	load_inventory()
func on_item_pick_up(item_data : ItemData, quantity : int):
	$UI.pick_up_item(item_data, quantity)
	pick_up.play()
func inventory_full():
	is_inventory_full = true

func inventory_not_full(item_id : int):
	is_inventory_full = false
	for child in dropped_items.get_children():
		if child.item_id == item_id :
			child.item_returned = false
			break
func return_dropped_items(quantity : int, item_id : int):
	for child in dropped_items.get_children():
		if child.item_id == item_id :
			child.quantity_label.text = str(quantity)
			child.item_returned = true
			break


