extends StaticBody2D

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var player = $"../player"
@onready var tile_map = self.get_parent()
@export var item_data : ItemData

var count : int = 0

@export var plant_stages : int
@export var item_name : String 

signal drop_items (drop_count : int, item_position : Vector2, item_data : ItemData, quantity : int, random_pos : bool)

var rng = RandomNumberGenerator.new() 

func _ready():
	add_to_group("crops")
	drop_items.connect(get_parent().get_parent().create_drop_items)
	timer.start()
	animation_player.play("crop_stages")
	
func _process(_delta):
	animation_player.seek(count)

func _on_timer_timeout():
	if count < plant_stages:
		count += 1
		timer.start()

func on_crop_click(crop_pos : Vector2i):
	if count == plant_stages and get_parent().local_to_map(position) == crop_pos:
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
		drop_items.emit(drop_count, position, item_data, 1, true)
		tile_map.set_cell(2, crop_pos, -1)
		queue_free()



