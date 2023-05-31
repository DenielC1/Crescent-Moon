extends CharacterBody2D

@export var inventory_data: InventoryData

const SPEED = 75
var starting_pos = Vector2(0,1)

@onready var Animation_Tree = $AnimationTree
@onready var State_Machine = Animation_Tree.get("parameters/playback")

var click : bool = false
var equipped : bool = false
var tabbed : bool = false

signal toggle_inventory

func _ready():
	Animation_Tree.set_active(true)
	Animation_Tree.set("parameters/idle/blend_position", starting_pos)
	Animation_Tree.set("parameters/axe/blend_position", starting_pos)

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
		Animation_Tree.set("parameters/idle/blend_position", input_direction)
		Animation_Tree.set("parameters/move/blend_position", input_direction)
		Animation_Tree.set("parameters/axe/blend_position", input_direction)

func pick_new_state():
	if click:
		State_Machine.travel("axe")
	else:
		if velocity != Vector2.ZERO:
			State_Machine.travel("move")
		else:
			State_Machine.travel("idle")

#use dictionary for slots?
func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory.emit()
		tabbed = not tabbed
	if !tabbed:
		if event.is_action_pressed("slot1"):
			equipped = not equipped
		if event.is_action_pressed("click") and click != true and equipped:
			click = true
			
func anim_ended():
	click = false
