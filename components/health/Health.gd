extends Node2D

class_name Health
	
@export var health : int

signal no_health

func damaged (damage):
	health -= damage
	if health == 0:
		no_health.emit()
	
