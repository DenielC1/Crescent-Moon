extends CharacterBody2D

@export var inventory_data: InventoryData

const SPEED = 75
var starting_pos = Vector2(0,1)

@onready var Animation_Tree = $AnimationTree
@onready var State_Machine = Animation_Tree.get("parameters/playback")

var current_slot : String
var prev_key : int = -1
var key : int = -1
var click : bool = false
var equipped : bool = false
var tabbed : bool = false

func _ready():
	Animation_Tree.set_active(true)
	Animation_Tree.set("parameters/Idle/blend_position", starting_pos)
	Animation_Tree.set("parameters/Axe/blend_position", starting_pos)
	Animation_Tree.set("parameters/Hoe/blend_position", starting_pos)
	Animation_Tree.set("parameters/Watering Can/blend_position", starting_pos)

func _physics_process(_delta):
	
	var input_direction = Vector2(Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),
	Input.get_action_strength("move_down")-Input.get_action_strength("move_up"))
	
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
		State_Machine.travel(current_slot)

	else:
		if velocity != Vector2.ZERO:
			State_Machine.travel("Move")
		else:
			State_Machine.travel("Idle")
			
func anim_ended():
	click = false

func _input(event):
	if event.is_action_pressed("inventory"):
		tabbed = not tabbed
	if !tabbed:
		if !click:
			if event is InputEventKey and event.pressed:
				key = event.keycode-49
				if key >= 0 and key <= 4:
					if event.is_action_pressed("slot%s" % (key+1) ):
						if current_slot == inventory_data.slot_datas[key].item_data.name:
							equipped = false
							current_slot = ""
						else:
							equipped = true
							current_slot = inventory_data.slot_datas[key].item_data.name
		if equipped:
			if event.is_action_pressed("click"):
				if inventory_data.slot_datas[0].item_data.type == "Tool":
						click = true
