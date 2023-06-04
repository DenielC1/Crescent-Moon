extends CanvasLayer

@onready var hotbar_grid = $Hotbar/hotbar_grid
@onready var inventory_grid = $Inventory/inventory_grid
@onready var grabbed_slot = $GrabbedSlot
@onready var player = $"../TileMap/player"

var grabbed_slot_data : SlotData
const Slot = preload("res://item/slot.tscn")

func _physics_process(_delta):
	if grabbed_slot.visible:
		grabbed_slot.tooltip_text = ""
		grabbed_slot.global_position = grabbed_slot.get_global_mouse_position() + Vector2(-2,2)
		
func on_item_clicked (index : int, button : int, type: String):
	if get_parent().player.tabbed:
		if type == "Inventory":
			index += 5
		#print("Index: %s  | Button: %s | Type: %s" % [index, button, type])
		if button == MOUSE_BUTTON_LEFT and grabbed_slot_data == null:
			grabbed_slot_data = player.inventory_data.slot_datas[index]
			if grabbed_slot_data: 
				grabbed_slot.import_item_data(grabbed_slot_data)
				player.inventory_data.slot_datas[index] = player.inventory_data.slot_datas[20] 
		elif button == MOUSE_BUTTON_LEFT and grabbed_slot_data:
			var selected_slot = player.inventory_data.slot_datas[index]
			if selected_slot and selected_slot.item_data.name == grabbed_slot_data.item_data.name and selected_slot.item_data.stackable:
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
			var selected_slot = player.inventory_data.slot_datas[index]
			if selected_slot and selected_slot.item_data.name == grabbed_slot_data.item_data.name and  selected_slot.quantity < 99:
				selected_slot.quantity += 1
				grabbed_slot_data.quantity -= 1
				if grabbed_slot_data.quantity <=0:
					grabbed_slot_data = null
					grabbed_slot.import_item_data(grabbed_slot_data)
			elif selected_slot == null:
				var new_slot_data = grabbed_slot_data.duplicate()
				new_slot_data.quantity = 1
				grabbed_slot_data.quantity -=1
				player.inventory_data.slot_datas[index] = new_slot_data
		if grabbed_slot_data:
			grabbed_slot.show()
		else: 
			grabbed_slot.hide()
		get_parent().load_inventory()
