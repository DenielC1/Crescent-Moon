extends StaticBody2D

@onready var tree_apple_sprites = $TreeAppleSprites
@onready var apple_trunk = $apple_trunk

@onready var animation_tree = $AnimationTree
@onready var State_Machine = animation_tree.get("parameters/playback")
@onready var main_body_hurtbox = $MainBodyHurtbox

func _ready():
	animation_tree.set_active(true)
	
func _on_health_no_health():
	tree_apple_sprites.set_visible(false)
	apple_trunk.set_visible(true)
	

func _on_hurtbox_hit():
	State_Machine.travel("hit")
