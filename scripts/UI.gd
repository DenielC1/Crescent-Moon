extends CanvasLayer

@onready var inventory_grid = $CenterContainer/HBoxContainer/Inventory/inventory_grid
@onready var grabbed_slot = $GrabbedSlot
@onready var player = $"../TileMap/player"
@onready var game = $".."
@onready var inventory_left_click = $"../Audio/Inventory_left_click"
@onready var inventory_right_click = $"../Audio/Inventory_right_click"
@onready var merchant_ui = $MerchantUI

var grabbed_slot_data : SlotData
const Slot = preload("res://item/slot/slot.tscn")
const Drop_slot = preload("res://item/item_drop/item_drop.tscn")
const Slot_resource = preload("res://inventory/slot_data.gd")
signal inventory_full
signal inventory_not_full(item_id : int)
signal return_dropped_items(quantity : int, item_id : int)

var item_id : int

func _ready():
	inventory_full.connect(get_parent().inventory_full)
	inventory_not_full.connect(get_parent().inventory_not_full)
	return_dropped_items.connect(get_parent().return_dropped_items)
func _physics_process(_delta):
	if global.is_selling_goods:
		merchant_ui.show()
	else:
		merchant_ui.hide()
		if grabbed_slot.visible:
			grabbed_slot.tooltip_text = ""
			grabbed_slot.global_position = grabbed_slot.get_global_mouse_position() + Vector2(-2,2)
		if grabbed_slot_data and !player.using_inventory:
				var item_position = player.position
				item_position.x += player.direction.x * 25
				item_position.y += player.direction.y * 25
				game.create_drop_items(1, item_position, grabbed_slot_data.item_data, grabbed_slot_data.quantity, false)
				grabbed_slot_data = null
				grabbed_slot.import_item_data(grabbed_slot_data)
func on_item_clicked (index : int, button : int, type: String):
	if get_parent().player.using_inventory and not global.is_selling_goods:
		if type == "Inventory":
			index += 5
		if type == "Chest":
			index += 20
		print("Index: %s  | Button: %s | Type: %s" % [index, button, type])
		if button == MOUSE_BUTTON_LEFT and grabbed_slot_data == null:
			inventory_left_click.play()
			grabbed_slot_data = player.inventory_data.slot_datas[index]
			if grabbed_slot_data and game.is_inventory_full:
				inventory_not_full.emit(item_id)
			elif !grabbed_slot_data and game.is_inventory_full:
				inventory_full.emit()
			if grabbed_slot_data: 
				grabbed_slot.import_item_data(grabbed_slot_data)
				player.inventory_data.slot_datas[index] = player.inventory_data.slot_datas[35] 
		elif button == MOUSE_BUTTON_LEFT and grabbed_slot_data:
			inventory_left_click.play()
			var selected_slot = player.inventory_data.slot_datas[index]
			if selected_slot and selected_slot.item_data.name == grabbed_slot_data.item_data.name and selected_slot.item_data.stackable and selected_slot.quantity < 99:
				if selected_slot.quantity+grabbed_slot_data.quantity > 99:
					grabbed_slot_data.quantity = selected_slot.quantity+grabbed_slot_data.quantity-99
					selected_slot.quantity = 99
				else:
					selected_slot.quantity += grabbed_slot_data.quantity
					grabbed_slot_data = null
				grabbed_slot.import_item_data(grabbed_slot_data)
			else:
				var temp = player.inventory_data.slot_datas[index]
				player.inventory_data.slot_datas[index] = grabbed_slot_data
				grabbed_slot_data = temp
				grabbed_slot.import_item_data(grabbed_slot_data)
		elif button == MOUSE_BUTTON_RIGHT and grabbed_slot_data and grabbed_slot_data.item_data.stackable:
			inventory_right_click.play()
			var selected_slot = player.inventory_data.slot_datas[index]
			if selected_slot and selected_slot.item_data.name == grabbed_slot_data.item_data.name and  selected_slot.quantity < 99:
				selected_slot.quantity += 1
				grabbed_slot_data.quantity -= 1
				if grabbed_slot_data.quantity <=0:
					grabbed_slot_data = null
			elif selected_slot == null:
				var new_slot_data = grabbed_slot_data.duplicate()
				new_slot_data.quantity = 1
				grabbed_slot_data.quantity -=1
				if grabbed_slot_data.quantity <=0:
					grabbed_slot_data = null
				player.inventory_data.slot_datas[index] = new_slot_data
			grabbed_slot.import_item_data(grabbed_slot_data)
		if grabbed_slot_data:
			grabbed_slot.show()
		else: 
			grabbed_slot.hide()
		get_parent().load_inventory()
	elif global.is_selling_goods:
		if type == "Inventory":
			index += 5
		if button == MOUSE_BUTTON_LEFT:
			var selected_slot =  player.inventory_data.slot_datas[index]
			if selected_slot and selected_slot.item_data.value != 0:
				selected_slot.quantity -= 1
				global.coins += selected_slot.item_data.value
				if selected_slot.quantity <= 0:
					player.inventory_data.slot_datas[index] = null
				get_parent().load_inventory()
				
func pick_up_item(item_data : ItemData, quantity : int):
	item_id = item_id
	if !is_inventory_full(item_data, quantity):
		inventory_not_full.emit(item_id)
		var index = 0
		for slot_data in player.inventory_data.slot_datas:
			if index >= 20:
				break
			if slot_data and slot_data.item_data.name == item_data.name and slot_data.quantity != 99 and item_data.stackable:
				if slot_data.quantity + quantity > 99:
					quantity =  slot_data.quantity + quantity - 99
					slot_data.quantity = 99 
					get_parent().load_inventory()
				else:
					slot_data.quantity += quantity
					get_parent().load_inventory()
				break
			index += 1
			
		if !item_data.stackable or index >= 20:
			index = 0
			for slot_data in player.inventory_data.slot_datas:
				if !slot_data:
					var new_slot_data = Slot_resource.new()
					new_slot_data.item_data = item_data
					if item_data.stackable:
						new_slot_data.quantity += quantity-new_slot_data.quantity
						player.inventory_data.slot_datas[index] = new_slot_data
						get_parent().load_inventory()
					else: 
						new_slot_data.quantity = 1
						quantity -= 1
						player.inventory_data.slot_datas[index] = new_slot_data
						get_parent().load_inventory()
					break
				index += 1
		if is_inventory_full(item_data, quantity):
			inventory_full.emit()
			return_dropped_items.emit(item_data, quantity, item_id)
	else:
		inventory_full.emit()
		
func is_inventory_full (item_data : ItemData, quantity : int):
	var index = 0
	for slot_data in player.inventory_data.slot_datas:
		if  index >= 20:
			return true
		if !slot_data:
			return false
		if slot_data.quantity < 99 and slot_data.item_data.stackable:
			if slot_data.item_data.name == item_data.name:
				return false
		index += 1
	return true
