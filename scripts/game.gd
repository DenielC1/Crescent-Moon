extends Node2D

var save_file_path = "user://save/"
var save_file_name = "PlayerSave.tres"

var player_data : PlayerData = PlayerData.new()
var chest_data : InventoryData

@onready var player = $TileMap/player
@onready var farmer_shop = $UI/CenterContainer/HBoxContainer/FarmerShop
@onready var farmer_grid = $UI/CenterContainer/HBoxContainer/FarmerShop/farmer_grid
@onready var hotbar_grid = $UI/Hotbar/hotbar_grid
@onready var inventory_grid = $UI/CenterContainer/HBoxContainer/Inventory/inventory_grid
@onready var chest_grid = $UI/CenterContainer/HBoxContainer/Chest/chest_grid
@onready var dropped_items = $TileMap/DroppedItems
@onready var selection = $UI/Hotbar/Selection
@onready var pick_up = $Audio/Pick_up
@onready var tile_map = $TileMap

@onready var clock = $Clock
@onready var coins = $Coins
@onready var ui = $UI
@onready var debug = $Debug

@onready var master = $pause_menu/CanvasLayer/Settings/PanelContainer/VBoxContainer/Master
@onready var music = $pause_menu/CanvasLayer/Settings/PanelContainer/VBoxContainer/Music
@onready var sfx = $pause_menu/CanvasLayer/Settings/PanelContainer/VBoxContainer/SFX

const Slot = preload("res://item/slot/slot.tscn")
const ItemDrop = preload("res://item/item_drop/item_drop.tscn")
const FarmerInventory = preload("res://inventory/farmer_inventory.tres")

var set_item_id = 0
var temp : int = -1
var is_escaped : bool = false 

var rng = RandomNumberGenerator.new() 
var item_position_x : float
var item_position_y : float

var has_chest_opened : bool = false

func _ready():
	var index = 0
	while index < 15:
		var slot_data = FarmerInventory.slot_datas[index]
		var slot = Slot.instantiate()
		if slot_data != null:
			slot.import_item_data(slot_data)
		farmer_grid.add_child(slot)
		index += 1
	global.data_loaded = false
	load_inventory()
	verify_save_directory(save_file_path)
	load_data()

func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)
	
func load_data():
	player_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	player_data.update_audio()
	player_data.update_data()
	player.position = player_data.player_pos
	player.inventory_data = player_data.inventory_data
	global.start_time = player_data.time
	if player_data.chest_inventory_datas == {}:
		get_tree().call_group("chest", "first_data_load")
	load_inventory()
	load_chest_datas()
	
func save_data():
	ResourceSaver.save(player_data, save_file_path + save_file_name)
	
func load_inventory():
	if has_chest_opened:
		var index = 0
		while index < 15:
			chest_data.slot_datas[index] = player.inventory_data.slot_datas[index + 20]
			index += 1
	for child in chest_grid.get_children():
		child.queue_free()
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
	while index >= 20 and index < 35:
		var slot_data = inventory.slot_datas[index]
		var slot = Slot.instantiate()
		if slot_data != null:
			slot.import_item_data(slot_data)
		chest_grid.add_child(slot)
		index += 1

func _process(_delta):
	if global.is_buying_goods:
		farmer_shop.show()
	else:
		farmer_shop.hide()
		select_slot()
		if global.is_selling_goods or has_chest_opened:
			player.using_inventory = true

		if player.using_inventory:
			$UI/CenterContainer/HBoxContainer/Inventory.show()
		else:
			$UI/CenterContainer/HBoxContainer/Inventory.hide()

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
	if event.is_action_pressed("escape") and not global.is_selling_goods and not global.is_buying_goods and not player.using_inventory:
		is_escaped = not is_escaped
		if is_escaped:
			global.game_paused = true
			get_tree().paused = true
		else:
			global.game_paused = false
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
	global.is_inventory_full = true

func inventory_not_full(item_id : int):
	global.is_inventory_full = false
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

func chest_opened(cd : InventoryData):
	has_chest_opened = true
	chest_data = cd
	var index = 0
	while index < 15:
		player.inventory_data.slot_datas[index + 20] = cd.slot_datas[index]
		index += 1
	load_inventory()
	$UI/CenterContainer/HBoxContainer/Chest.show()

func chest_closed():
	has_chest_opened = false
	player.using_inventory = false
	$UI/CenterContainer/HBoxContainer/Chest.hide()

func load_chest_datas():
	for id in global.chest_inventory_datas:
		for child in tile_map.get_children():
			if child.is_in_group("chest"):
				if child.id == id:
					child.chest_data = global.chest_inventory_datas.get(id)



func _on_dropped_item_timer_timeout():
	for child in $TileMap/DroppedItems.get_children():
		child.queue_free()
	$DroppedItemTimer.start()
