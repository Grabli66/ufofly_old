
extends Node2D

const SPEED = 50
var width = 0

# moves textures
func _process(delta):
#	var pos = get_pos()
#	pos.x -= SPEED * delta	
#	if pos.x < -width:
#		pos.x = 0
#	set_pos(pos)
	pass
	

func _ready():
	width = get_node("ParalaxTexture1").get_size().width
	set_process(true)


