extends StaticBody2D

func _on_health_no_health():
	$Tree.set_visible(false)
	$Trunk.set_visible(true)
	
