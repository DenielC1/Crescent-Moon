extends Area2D

@export var damage = 1 
var tool_type : String

func _on_player_item_swapped():
	tool_type = get_parent().current_tool_slot
