extends StaticBody2D

func _on_health_no_health():
	$Big_Tree.set_visible(false)
	$Big_Tree_Trunk.set_visible(true)
