extends Area2D

@export var Health : Health

func _on_area_entered(area):
	print("a")
	Health.damaged(area.damage)

