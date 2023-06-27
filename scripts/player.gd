extends CharacterBody2D

@export var inventory_data: InventoryData

const SPEED = 50
var starting_pos : Vector2 = Vector2(0,1)
var direction : Vector2 = Vector2(0,1)

@onready var Animation_Tree = $AnimationTree
@onready var State_Machine = Animation_Tree.get("parameters/playback")
@onready var tile_map = self.get_parent()

@export var crop_list : Dictionary
@export var crop_instances : Dictionary
@export var tile_layers : Dictionary

signal item_swapped
signal use_item_slot(slot_data : SlotData)

var current_state : String 
var current_tool_slot : String  = "null"
var current_slot : String = "null"
var slot : SlotData

var key : int = -1
var index: int = -1

var click : bool = false
var using_inventory : bool = false

var soil_tiles =  []
var watered_tiles = []

func _ready():
	use_item_slot.connect(get_parent().get_parent().use_item_slot)
	Animation_Tree.set_active(true)
	Animation_Tree.set("parameters/Idle/blend_positdion", starting_pos)
	Animation_Tree.set("parameters/Axe/blend_position", starting_pos)
	Animation_Tree.set("parameters/Hoe/blend_position", starting_pos)
	Animation_Tree.set("parameters/Watering Can/blend_position", starting_pos)

func _physics_process(_delta):
	tile_selector()
	if not global.is_talking and not using_inventory:
		var input_direction = Vector2(Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down")-Input.get_action_strength("move_up"))
		
		if input_direction != Vector2.ZERO:
			direction = input_direction
		if click:
			velocity = Vector2.ZERO
			input_direction = Vector2.ZERO
		else:
			velocity = input_direction.normalized()*SPEED

		update_animations(input_direction)
		
		pick_new_state()
		
		move_and_slide()
	else:
		State_Machine.travel("Idle")
	

func update_animations (input_direction):
	if input_direction != Vector2.ZERO:
		Animation_Tree.set("parameters/Idle/blend_position", input_direction)
		Animation_Tree.set("parameters/Move/blend_position", input_direction)
		Animation_Tree.set("parameters/Axe/blend_position", input_direction)
		Animation_Tree.set("parameters/Hoe/blend_position", input_direction)
		Animation_Tree.set("parameters/Watering Can/blend_position", input_direction)

func pick_new_state():
	if click:
		current_state = current_tool_slot
		State_Machine.travel(current_state)
	else:
		if velocity != Vector2.ZERO:
			current_state = "Move"
			State_Machine.travel(current_state)
		else:
			current_state = "Idle"
			State_Machine.travel(current_state)

func tile_selector ():
	if slot and slot.quantity <= 0:
		current_tool_slot = "null"
		current_slot = "null"
		slot = null
	if not global.is_talking and slot and (current_tool_slot == "Hoe" or current_tool_slot == "Watering Can" or slot.item_data.type == "Seeds"):
		tile_map.clear_layer(tile_layers.get("Tile_Selector"))
		var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
		tile_map.set_cell(tile_layers.get("Tile_Selector"), clicked_cell, 6, Vector2.ZERO)
	else:
		tile_map.clear_layer(tile_layers.get("Tile_Selector"))

func anim_ended():
	click = false

func _input(event):
	if not global.is_talking:
		if event.is_action_pressed("inventory") and !click:
			using_inventory = not using_inventory
			index = -1
			current_tool_slot = "null"
			current_slot = "null"
			key = -1
		if !using_inventory and !click:
			if current_tool_slot != "null" and inventory_data.slot_datas[index] and event.is_action_pressed("click"):
				click = true
				var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
				var data = tile_map.get_cell_tile_data(tile_layers.get("Land"), clicked_cell)
				if data and data.get_custom_data("Farmable") and current_tool_slot == "Hoe":
					if (get_local_mouse_position().x <= 24 and get_local_mouse_position().x >= -24) and (get_local_mouse_position().y <= 24 and get_local_mouse_position().y >= -24): 
						soil_tiles.append(clicked_cell)
						tile_map.set_cells_terrain_connect(tile_layers.get("Soil"), soil_tiles, 1, 0)
						for tile in watered_tiles:
							tile_map.set_cell(tile_layers.get("Watered Tiles"), tile, 1, tile_map.get_cell_atlas_coords(tile_layers.get("Soil"), tile))
				elif slot and current_tool_slot == "Watering Can" and event.get_action_strength("click") and tile_map.get_cell_source_id(tile_layers.get("Soil"), clicked_cell) == 0:
					if (get_local_mouse_position().x <= 24 and get_local_mouse_position().x >= -24) and (get_local_mouse_position().y <= 24 and get_local_mouse_position().y >= -24): 
						watered_tiles.append(clicked_cell)
						tile_map.set_cell(tile_layers.get("Watered Tiles"), clicked_cell, 1, tile_map.get_cell_atlas_coords(tile_layers.get("Soil"), clicked_cell))
						get_tree().call_group("crops", "on_soil_watered", clicked_cell)
				var click_direction = get_local_mouse_position()
				update_animations(click_direction)
			elif slot and slot.item_data.type == "Seeds" and event.get_action_strength("click"):
				var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
				var data = tile_map.get_cell_tile_data(tile_layers.get("Soil"), clicked_cell)
				if data and data.get_custom_data("Tile Type") == "Soil" and tile_map.get_cell_source_id(tile_layers.get("Objects"), clicked_cell) == -1:
					if (get_local_mouse_position().x <= 24 and get_local_mouse_position().x >= -24) and (get_local_mouse_position().y <= 24 and get_local_mouse_position().y >= -24):
						tile_map.set_cell(tile_layers.get("Objects"), clicked_cell, 9, Vector2i(0, 0))
						var crop = (crop_instances.get(crop_list.get(slot.item_data.name))).instantiate()
						crop.position = tile_map.map_to_local(clicked_cell)
						tile_map.add_child(crop)
						use_item_slot.emit(slot)
						if tile_map.get_cell_tile_data(tile_layers.get("Watered Tiles"), clicked_cell):
							get_tree().call_group("crops", "on_soil_watered", clicked_cell)
			elif !slot and event.get_action_strength("click"):
				if (get_local_mouse_position().x <= 24 and get_local_mouse_position().x >= -24) and (get_local_mouse_position().y <= 24 and get_local_mouse_position().y >= -24): 
					var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
					if tile_map.get_cell_source_id(tile_layers.get("Objects"), clicked_cell) == 9:
						var obj_type = tile_map.get_cell_alternative_tile(tile_layers.get("Objects"), clicked_cell)
						if obj_type != 7:
							get_tree().call_group("crops", "on_crop_click", clicked_cell, tile_layers.get("Objects"))
			if event is InputEventKey and event.pressed:
				key = event.keycode-49
				if key >= 0 and key <= 4:
					if index != key:
						if event.is_action_pressed("slot%s" % (key+1) ):
							slot = inventory_data.slot_datas[key]
							if slot:
								if slot.item_data.type == "Tool":
									current_tool_slot = slot.item_data.name
								else:
									current_tool_slot = "null"
								current_slot = slot.item_data.name
								item_swapped.emit()
							else:
								current_tool_slot = "null"
								current_slot = "null"
								slot = null
								item_swapped.emit()
						index = key
					else:
						index = -1
						current_tool_slot = "null"
						current_slot = "null"
						slot = null

func check_current_tile():
	pass
