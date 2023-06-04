extends StaticBody2D

signal item_pick_up (item_data : ItemData, quantity : int)

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var item = $Item
@onready var quantity = $Quantity

var item_data : ItemData

func _ready():
	item_pick_up.connect(get_parent().get_parent().get_parent().on_item_pick_up)
	item.text = item_data.name
	sprite_2d.texture = item_data.texture
	animation_player.play("item_idle")
	
func _on_hurtbox_area_entered(_area):
	print("picked")
	queue_free()
	item_pick_up.emit(item_data, int($Quantity.text))
	
