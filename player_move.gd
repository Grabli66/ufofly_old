
extends Node2D

var speed = 30
var player

func _process(delta):
	var pos = get_pos()
	pos.x += speed * delta
	pos.y += player.get_pos().y * delta
	set_pos(pos)

func _ready():
	player = get_node("Player")
	get_node("/root/global").player = self
	set_process(true)


