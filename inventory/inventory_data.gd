extends Resource

class_name InventoryData

signal inventory_interact(inventory_data: InventoryData, index: int, button: int)
signal update_inventory(inventory_data: InventoryData)
signal inventory_key_interact(inventory_data: InventoryData, index: int)

@export var slot_datas: Array[SlotData]

func grab_slot_data(index):
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		update_inventory.emit(self)
		return slot_data
	else:
		return null
		
func drop_slot_data(grabbed_slot_data, index):
	var slot_data = slot_datas[index]
	var return_slot_data: SlotData
	
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
	update_inventory.emit(self)
	return return_slot_data
	
func drop_single_slot_data(grabbed_slot_data, index):
	var slot_data = slot_datas[index]
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	update_inventory.emit(self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null
func update_key(index):
	pass
func on_slot_clicked(index: int, button: int):
	inventory_interact.emit(self, index, button)
	
func on_hotbar_key_clicked(index: int):
	inventory_key_interact.emit(self, index)


