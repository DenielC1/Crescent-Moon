extends Control

@onready var player_inventory = $HBoxContainer/VBoxContainer/PlayerInventory
@onready var item_grid = $HBoxContainer/VBoxContainer/PlayerInventory/ItemGrid
@onready var grabbed_slot = $GrabbedSlot
var grabbed_slot_data: SlotData


func _physics_process(_delta):
	if grabbed_slot.visible:
		grabbed_slot.tooltip_text = ""
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(-2,2)
		
func set_player_inventory_data(inventory_data : InventoryData):
		inventory_data.inventory_interact.connect(on_inventory_interact)
		inventory_data.inventory_key_interact.connect(on_inventory_key_interact)
		player_inventory.set_inventory_data(inventory_data)
	
		
func on_inventory_interact(inventory_data: InventoryData, index: int, button: int):
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			pass
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
	update_grabbed_slot()
	
func on_inventory_key_interact(inventory_data: InventoryData, index: int):
	inventory_data.update_key(index)
	
func update_grabbed_slot():
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()
