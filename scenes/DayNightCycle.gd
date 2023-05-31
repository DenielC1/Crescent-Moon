extends CanvasModulate

@export var time_anim : AnimationPlayer
@export var start_time : float = 12.0
var time = start_time

func _ready():
	time_anim.play("DayNightCycle")
	time_anim.seek(start_time)
func _process(_delta):
	time = fmod(start_time + (Time.get_ticks_msec()/1000.0)/64, 24)
	time_anim.seek(time, true)
