extends StaticBody2D

signal item_pick_up (item_data : ItemData, quantity : int, item_id : int)

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var item = $Item
@onready var quantity_label = $Quantity

@onready var game = get_parent().get_parent().get_parent() 

var item_data : ItemData
var item_returned : bool = false
var item_id : int

func _ready():
	item_pick_up.connect(game.on_item_pick_up)
	item.text = item_data.name
	sprite_2d.texture = item_data.texture
	animation_player.play("item_idle")
	
func _on_hurtbox_area_entered(_area):
	item_pick_up.emit(item_data, int(quantity_label.text))
	if (!global.is_inventory_full and !item_returned) or int(quantity_label.text) == 0 :
		queue_free()
		
