extends CharacterBody2D

const SPEED = 75
var starting_pos = Vector2(0,1)

@onready var Animation_Tree = $AnimationTree
@onready var State_Machine = Animation_Tree.get("parameters/playback")

func _ready():
	Animation_Tree.set_active(true)
	Animation_Tree.set("parameters/idle/blend_position", starting_pos)

func _physics_process(_delta):
	var input_direction = Vector2(Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),
	Input.get_action_strength("move_down")-Input.get_action_strength("move_up"))
	
	velocity = input_direction.normalized()*SPEED
	
	update_animations(input_direction)
	
	pick_new_state()
	
	move_and_slide()



func update_animations (input_direction):
	if input_direction != Vector2.ZERO:
		Animation_Tree.set("parameters/idle/blend_position", input_direction)
		Animation_Tree.set("parameters/move/blend_position", input_direction)


func pick_new_state():
	if velocity != Vector2.ZERO:
		State_Machine.travel("move")
	else:
		State_Machine.travel("idle")
