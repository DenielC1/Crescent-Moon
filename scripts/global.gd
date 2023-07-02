extends Node

var data_loaded = false

var day : int = 1
@export var start_time : float = 12
@onready var game_time = [0,0] 
var actual_time : float
@onready var time_state : String = "" 

@export var chest_inventory_datas : Dictionary

var coins : int = 0
var id : int = 0

var morning : float = 5
var afternoon: float = 12
var evening : float = 17
var night : float = 21

var is_inventory_full = false
var is_talking = false
var is_selling_goods = false
var is_buying_goods = false
var can_move = true
var game_paused = false

func _ready():
	game_time[0] = start_time
	check_time_state()
	
func _process(_delta):
	check_time_state()
	check_player_action()
func check_player_action():
	if is_talking or is_selling_goods or is_buying_goods:
		can_move = false
	else:
		can_move = true
func _input(event):
	if is_selling_goods or is_buying_goods:
		if event.is_action_pressed("escape") or event.is_action_pressed("inventory"):
			is_selling_goods = false
			is_buying_goods = false
func check_time_state():
	var hour = game_time[0]
	if hour >= morning and hour < afternoon:
		time_state = "Morning"
	elif hour >= afternoon and hour < evening:
		time_state = "Afternoon"
	elif hour >= evening and hour < night:
		time_state = "Evening"
	elif hour >= night or hour < morning:
		time_state = "Night" 
