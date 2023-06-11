extends CharacterBody2D

@export var inventory_data: InventoryData

const SPEED = 75
var starting_pos : Vector2 = Vector2(0,1)
var direction : Vector2 = Vector2(0,1)

@onready var Animation_Tree = $AnimationTree
@onready var State_Machine = Animation_Tree.get("parameters/playback")
@onready var tile_map = self.get_parent()

signal item_swapped

var current_state : String 
var current_tool_slot : String  = "null"
var current_slot : String = "null"

var key : int = -1
var index: int = -1

var click : bool = false
var tabbed : bool = false

func _ready():
	Animation_Tree.set_active(true)
	Animation_Tree.set("parameters/Idle/blend_position", starting_pos)
	Animation_Tree.set("parameters/Axe/blend_position", starting_pos)
	Animation_Tree.set("parameters/Hoe/blend_position", starting_pos)
	Animation_Tree.set("parameters/Watering Can/blend_position", starting_pos)

func _physics_process(_delta):
	if current_tool_slot == "Hoe":
		tile_map.clear_layer(3)
		var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
		tile_map.set_cell(3, clicked_cell, 6, Vector2.ZERO)
	else:
		tile_map.clear_layer(3)
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

func anim_ended():
	click = false

func _input(event):
	if event.is_action_pressed("inventory") and !click:
		tabbed = not tabbed
		index = -1
		current_tool_slot = "null"
		current_slot = "null"
		key = -1
	if !tabbed and !click:
		if current_tool_slot != "null" and inventory_data.slot_datas[index] and event.is_action_pressed("click"):
			click = true
			var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
			var data = tile_map.get_cell_tile_data(1, clicked_cell)
			if data and data.get_custom_data("Farmable") and current_tool_slot == "Hoe":
				if (get_local_mouse_position().x <= 24 and get_local_mouse_position().x >= -24) and (get_local_mouse_position().y <= 24 and get_local_mouse_position().y >= -24): 
					tile_map.set_cell(1, clicked_cell, 4, Vector2(1, 1))
			var click_direction = get_local_mouse_position()
			update_animations(click_direction)
		if event is InputEventKey and event.pressed:
			key = event.keycode-49
			if key >= 0 and key <= 4:
				if index != key:
					if event.is_action_pressed("slot%s" % (key+1) ):
						if inventory_data.slot_datas[key]:
							var slot = inventory_data.slot_datas[key].item_data
							if slot.type == "Tool":
								current_tool_slot = slot.name
							else:
								current_tool_slot = "null"
							current_slot = slot.name
							item_swapped.emit()
						else:
							current_tool_slot = "null"
							current_slot = "null"
							item_swapped.emit()
					index = key
				else:
					index = -1
					current_tool_slot = "null"
					current_slot = "null"

func check_current_tile():
	pass
