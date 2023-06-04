extends StaticBody2D

@onready var tree_apple_sprites = $TreeAppleSprites
@onready var apple_trunk = $apple_trunk

@onready var animation_tree = $AnimationTree
@onready var State_Machine = animation_tree.get("parameters/playback")
@onready var main_body_hurtbox = $MainBodyHurtbox

@export var item_data : ItemData

signal drop_items (drop_count : int, item_position : Vector2, item_data : ItemData, quantity : int)

const item_name : String = "Wood"
var rng = RandomNumberGenerator.new() 

func _ready():
	animation_tree.set_active(true)
	drop_items.connect(get_parent().get_parent().get_parent().create_drop_items)
func _on_health_no_health():
	tree_apple_sprites.set_visible(false)
	apple_trunk.set_visible(true)
	
	randomize()
	var drop_count = rng.randf()
	if drop_count <= 0.35:
		drop_count = 2
	elif drop_count <= 0.7:
		drop_count = 3
	elif drop_count <= 0.9:
		drop_count = 4
	else: 
		drop_count = 5
		
	drop_items.emit(drop_count, position, item_data, 1)
	
func _on_hurtbox_hit():
	State_Machine.travel("hit")


