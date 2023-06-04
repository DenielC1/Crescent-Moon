extends Area2D

@export var Health : Health

signal hit 

func _on_area_entered(area):
	if area.tool_type == "Axe":
		hit.emit()
		Health.damaged(area.damage)

