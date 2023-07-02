extends StaticBody2D

@export var chest_data : InventoryData = preload("res://inventory/chest.tres")
@export var id : int 
@onready var animation_player = $AnimationPlayer

@onready var player_data = get_parent().get_parent().player_data
var in_range = false
var opened = false

signal chest_opened(chest_data : InventoryData)
signal chest_close


func _ready():
	chest_data = chest_data.duplicate()
	add_to_group("chest")
	id = global.id
	global.id += 1
	chest_opened.connect(get_parent().get_parent().chest_opened)
	chest_close.connect(get_parent().get_parent().chest_closed)
func _input(event):
	if event.is_action_pressed("interact") and in_range and not opened:
		opened = true
		animation_player.play("open")
		chest_opened.emit(chest_data)
	elif event.is_action_pressed("interact") and opened:
		animation_player.play("close")
		opened = false
		chest_close.emit()

func _on_player_detection_area_entered(_area):
	in_range = true

func _on_player_detection_area_exited(_area):
	in_range = false

func first_data_load():
	global.chest_inventory_datas[id] = chest_data

