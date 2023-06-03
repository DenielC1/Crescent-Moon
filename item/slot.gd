extends PanelContainer



func import_item_data(slot_data : SlotData):
	var item_data = slot_data.item_data
	$Icon.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description] 
	if slot_data.quantity > 1:
		$QuantityLabel.text = "%s" % slot_data.quantity
	
