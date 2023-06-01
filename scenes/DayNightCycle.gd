extends CanvasModulate

@export var time_anim : AnimationPlayer
@export var start_time : float = 12
var time = start_time
var prev_time : Vector2

var morning : float = 4
var afternoon: bool = false
var evening : bool = false
var night : float = 21

func _ready():
	time_anim.play("DayNightCycle")
	time_anim.seek(start_time)
	
func _process(_delta):
	time = fmod(start_time + (Time.get_ticks_msec()/1000.0)/64, 24)
	time_anim.seek(time, true)

	
	if time >= night or time <= (morning-0.05):
		get_tree().call_group("cows", "sleep_time")
	elif time <= morning and time >= (morning-0.05):
		get_tree().call_group("cows", "wake_up")
