extends PanelContainer

signal item_clicked (index : int, button : int, type: String)

func _ready():
	if get_parent().name != "UI":
		item_clicked.connect(get_parent().get_parent().get_parent().on_item_clicked)

func import_item_data(slot_data : SlotData):
	if slot_data:
		var item_data = slot_data.item_data
		$Icon.texture = item_data.texture
		tooltip_text = "%s\n%s" % [item_data.name, item_data.description] 
		if slot_data.quantity > 1:
			$QuantityLabel.text = "%s" % slot_data.quantity
	else:
		$Icon.texture = null
		tooltip_text = ""
		$QuantityLabel.text = ""
func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var type = get_parent().get_parent().name
		item_clicked.emit(get_index(), event.button_index, type)
