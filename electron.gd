
extends Sprite

var speed = 150

func _process(delta):
	rotate(deg2rad(-speed*delta))

func _ready():
	set_process(true)
	pass


