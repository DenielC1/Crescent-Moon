extends CharacterBody2D

@onready var Animation_Tree = $AnimationTree
@onready var State_Machine = Animation_Tree.get("parameters/playback")
@onready var Wander_Timer = $WanderTimer
@onready var Detection_Timer = $DetectionTimer
@onready var Sprite = $Sprite2D

const SPEED = 25

var rng = RandomNumberGenerator.new()
var wander_time : int
var detection_time : int

var direction : Vector2
var old_direction : Vector2
var pos_x : float
var pos_y : float

var tileset_collided = false
var entity_collided = false

func random_direction():
	pos_x = rng.randi_range(-1, 1)
	pos_y = rng.randi_range(-1, 1)
	while pos_x == 0 and pos_y != 0:
		pos_x = rng.randi_range(-1, 1)
		pos_y = rng.randi_range(-1, 1)
	if tileset_collided:
		pos_x = old_direction.x * -1
	direction = Vector2(pos_x, pos_y)
	old_direction = direction
	
func _ready():
	Animation_Tree.set_active(true)
	wander_time = rng.randi_range(1, 8)
	Wander_Timer.set_wait_time(wander_time)
	Wander_Timer.start()
	random_direction()
	
func _physics_process(_delta):
	if !entity_collided:
		if is_on_wall() and tileset_collided != true:
			tileset_collided = true
			old_direction = direction
			direction = Vector2.ZERO
		elif not is_on_wall():
			tileset_collided = false
		if tileset_collided == false:
			Sprite.flip_h = old_direction.x < 0
	velocity = direction.normalized() * SPEED
	pick_new_state()
	move_and_slide()

func pick_new_state():
	if velocity != Vector2.ZERO:
		State_Machine.travel("walk")
	else:
		State_Machine.travel("idle")

func _on_wander_timer_timeout():
	if !entity_collided:
		random_direction()
		wander_time = rng.randi_range(1, 8)
		Wander_Timer.set_wait_time(wander_time)

func _on_detection_area_body_entered(_body):
	entity_collided = true
	old_direction.x = direction.x
	direction = Vector2.ZERO
	detection_time = rng.randi_range(3,3)
	Detection_Timer.set_wait_time(detection_time)
	Detection_Timer.start()
	
func _on_detection_area_body_exited(_body):
	entity_collided = false
	wander_time = rng.randi_range(1, 3)
	Wander_Timer.set_wait_time(wander_time)
	
func _on_detection_timer_timeout():
	entity_collided = false
