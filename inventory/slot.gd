extends PanelContainer


@onready var quantity_label = $Background/QuantityLabel
@onready var icon =  $Icon
var equipped = false

signal slot_clicked(index: int, button: int)
signal hotbar_key_clicked(index: int)

func set_slot_data(slot_data: SlotData):
	var item_data = slot_data.item_data
	icon.texture = item_data.texture
	#tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	
	if slot_data.quantity > 1 and item_data.stackable:
		quantity_label.text = "%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()

func _on_gui_input(event):
	if event is InputEventMouseButton \
		and (event.button_index == MOUSE_BUTTON_LEFT \
		or event.button_index == MOUSE_BUTTON_RIGHT) and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)

func _input(event):
	if get_index() > 14:
		if event.is_action_pressed("slot%s" % [get_index()-int(14)]):
			equipped = not equipped
			if equipped:
				print("slot%s" % [get_index()-int(14)])
				print(quantity_label.text)
				self.modulate = Color(0.52941179275513, 0.52941179275513, 0.52941179275513)
			else:
				self.modulate = Color(1, 1, 1)
