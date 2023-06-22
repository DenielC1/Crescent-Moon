extends PanelContainer

signal item_clicked (index : int, button : int, type: String)

const toolip_box_theme = preload("res://themes/tooltip_box.tres")

var tabbed : bool = false 

var temp : String

var type : String

func _ready():
	if get_parent().name != "UI":
		if get_parent().name == "inventory_grid":
			item_clicked.connect(get_parent().get_parent().get_parent().get_parent().on_item_clicked)
			type = get_parent().get_parent().name
		elif get_parent().name == "hotbar_grid":
			item_clicked.connect(get_parent().get_parent().get_parent().on_item_clicked)
			type = get_parent().get_parent().name

func import_item_data(slot_data : SlotData):
	if slot_data:
		var item_data = slot_data.item_data
		$Icon.texture = item_data.texture
		$Icon/TextureRect.set_theme(toolip_box_theme)
		$Icon/TextureRect/VBoxContainer/item_name.text = item_data.name
		$Icon/TextureRect/VBoxContainer/Tooltip.text = item_data.description
		if slot_data.quantity >= 1 and item_data.stackable:
			$QuantityLabel.text = "%s" % slot_data.quantity
	else:
		$Icon.texture = null
		tooltip_text = ""
		$QuantityLabel.text = ""

func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		item_clicked.emit(get_index(), event.button_index, type)

func _input(event):
	if event.is_action_pressed("inventory"):
		tabbed = not tabbed
		if not tabbed:
			$Icon/TextureRect.hide()
			$Timer.stop()

func _on_mouse_entered():
	$Timer.start()

func _on_mouse_exited():
	$Icon/TextureRect.hide()
	$Timer.stop()

func _on_timer_timeout():
	$Icon/TextureRect.show()
	


	
