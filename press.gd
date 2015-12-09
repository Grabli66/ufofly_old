
extends Node2D

var player
var press_anim

func kill_object(body):
	if body.has_method("kill"):
		body.kill()

func _fixed_process(delta):
	var pos = get_pos()
	if pos.x < player.get_pos().x - 50:
		set_fixed_process(false)
		queue_free()

func _ready():
	player = get_node("/root/global").player
	press_anim = get_node("PressAnim")
	press_anim.play("work")
	set_fixed_process(true)

func _on_Moving_body_enter( body ):
	kill_object(body)


func _on_Static_body_enter( body ):
	kill_object(body)
