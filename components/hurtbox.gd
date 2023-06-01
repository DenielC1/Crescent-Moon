extends Area2D

@export var Health : Health

signal hit 

func _on_area_entered(area):
	hit.emit()
	Health.damaged(area.damage)

