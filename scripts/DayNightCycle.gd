extends CanvasModulate

@onready var timer = $Timer
@export var time_anim : AnimationPlayer
var time : float 

var hour : int 
var time_period : String

func _ready():
	time_anim.play("DayNightCycle")
	time_anim.seek(global.start_time)
func _process(_delta):
	var temp = int(time)
	if temp == 0:
		temp = 1
	global.game_time = [int(time), int(fmod(time,temp)*60)]
	if global.game_time[0] >= 12:
		if global.game_time[0] == 12:
			hour = global.game_time[0]/12
		else:
			hour = int(fmod(global.game_time[0],12))
		time_period = "PM"
	else:
		hour = global.game_time[0]
		time_period = "AM"
	$"../Clock/NinePatchRect/HBoxContainer/Label".text = "%02d:%02d" % [hour, global.game_time[1]] + time_period
	#print(global.start_time + (1440-timer.time_left)/60)
	if hour == 24:
		global.day += 1
	$"../Day/NinePatchRect/HBoxContainer/Label".text = "August %d" % global.day
	time = fmod(global.start_time + (1440-timer.time_left)/60, 24)
	global.actual_time = time
	time_anim.seek(time)
	if time > global.night or time < global.morning:
		get_tree().call_group("cows", "is_sleeping")
	elif time >= global.night-0.0025 and time <= global.night:
		get_tree().call_group("cows", "go_sleep")
	elif time >= global.morning and time <= (global.morning+0.0025):
		get_tree().call_group("cows", "wake_up")


func _on_timer_timeout():
	print("24 HOUR PASS")
	timer.start()
