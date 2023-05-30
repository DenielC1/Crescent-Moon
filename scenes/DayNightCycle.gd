extends CanvasModulate

@export var time_anim : AnimationPlayer
@export var start_time : float = 12.0

func _ready():
	time_anim.play("DayNightCycle")
	time_anim.seek(start_time)

func _process(_delta):
	time_anim.seek(start_time + (Time.get_ticks_msec()/1000.0)/60.0)
