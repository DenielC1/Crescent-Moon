extends StaticBody2D

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var player = $"../player"
@onready var tile_map = self.get_parent()
@export var item_data : ItemData

@export var crop_life : float = 0

@export var plant_stages : int
@export var item_name : String 

signal drop_items (drop_count : int, item_position : Vector2, item_data : ItemData, quantity : int, random_pos : bool)

var rng = RandomNumberGenerator.new() 

@onready var crop_pos = get_parent().local_to_map(position)

@export var crop_growth : float = 0

func _ready():
	add_to_group("crops")
	drop_items.connect(get_parent().get_parent().create_drop_items)
	timer.start()
	animation_player.play("crop_stages")
	
func _process(_delta):
	animation_player.seek(crop_life)
	
func _on_timer_timeout():
	if crop_life < plant_stages:
		print(crop_life)
		crop_life += crop_growth
		timer.start()

func on_soil_watered(crop_tile_pos : Vector2i):
	if crop_pos == crop_tile_pos:
		crop_growth = 1.2

func on_crop_click(crop_tile_pos : Vector2i, layer : int):
	if crop_life >= plant_stages and crop_pos == crop_tile_pos:
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
		tile_map.set_cell(layer, crop_pos, -1)
		queue_free()



