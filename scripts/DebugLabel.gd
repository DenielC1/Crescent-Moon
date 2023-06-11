extends RichTextLabel

@onready var debug = $"../.."
@onready var player = $"../../../TileMap/player"
@onready var game = $"../../.."
@onready var day_night_cycle = $"../../../DayNightCycle"

func _input(event):
	if event.is_action_pressed("debug"):
		if !debug.is_visible():
			debug.show()
		else:
			debug.hide()

func _process(_delta):
	var temp = int(day_night_cycle.time)
	if temp == 0:
		temp = 1
	text = "FPS: %s" % Engine.get_frames_per_second() \
	+ "\nPlayer Position: %s" %  Vector2(int(player.position.x), int(player.position.y)) \
	+ "\nPlayer Direction: %s" % player.direction \
	+ "\nCurrent Item: %s" % player.current_slot \
	+ "\nCurrent State: %s" % player.current_state \
	+ "\nSlot Index: %s" % (player.index + 1) \
	+ "\nInventory Status: %s" % game.is_inventory_full \
	+ "\nTime: %d:%02d" % [int(day_night_cycle.time), int(fmod(day_night_cycle.time,temp)*60)]
