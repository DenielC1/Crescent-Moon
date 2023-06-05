extends RichTextLabel

@onready var debug = $"../.."
@onready var player = $"../../../TileMap/player"

func _input(event):
	if event.is_action_pressed("debug"):
		if !debug.is_visible():
			debug.show()
		else:
			debug.hide()

func _process(_delta):
	text = "FPS: %s" % Engine.get_frames_per_second() \
	+ "\nPlayer Position: %s" %  Vector2(int(player.position.x), int(player.position.y)) \
	+ "\nCurrent Item: %s" % player.current_slot \
	+ "\nCurrent State: %s" % player.current_state \
	+ "\nSlot Index: %s" % (player.index + 1)
	
