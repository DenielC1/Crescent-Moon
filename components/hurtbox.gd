extends Area2D

@export var Health : Health

func _on_area_entered(area):
	print("hit")
	Health.damaged(area.damage)

