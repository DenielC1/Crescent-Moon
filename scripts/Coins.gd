extends CanvasLayer

@onready var label = $NinePatchRect/HBoxContainer/Label

func _process(_delta):
	label.text = "%d" % global.coins

