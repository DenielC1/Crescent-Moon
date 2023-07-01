extends StaticBody2D

const Balloon = preload("res://entity/npc/dialogue/small_balloon.tscn")
@onready var animation_player = $AnimationPlayer

@export var dialogue_resource : DialogueResource
@export var dialogue_start : String = "start"

var player_detected = false

func _ready():
	animation_player.play("idle_anim")
	
func _input(event):
	if event.is_action_pressed("interact") and player_detected and not global.is_talking:
		var balloon = Balloon.instantiate() 
		get_tree().current_scene.add_child(balloon)
		balloon.start(dialogue_resource, dialogue_start)
		balloon.image.texture = $TextureRect.texture

func _on_player_detection_area_entered(_area):
	player_detected = true


func _on_player_detection_area_exited(_area):
	player_detected = false
