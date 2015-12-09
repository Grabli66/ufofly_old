
extends RigidBody2D

var world
var speed = 0
var player

func add_impulse(impulse):
	set_linear_velocity(impulse)

# kills ateroig
func kill():
	var pos = get_pos()
	set_fixed_process(false)
	var ex = preload("res://explosion.scn").instance()
	world.add_child(ex)
	ex.explode(pos)
	queue_free()

# hits asteroig
func hit():
	if (rand_range(0,100) > 70):
		kill()

func _fixed_process(delta):
	var pos = get_pos()

	if pos.x < player.get_pos().x - 50:
		set_fixed_process(false)
		queue_free()

	if get_colliding_bodies().size() > 0:
		hit()

func _ready():
	player = get_node("/root/global").player
	world = get_node("/root/global").world
	speed = rand_range(50,150)
	set_fixed_process(true)
	set_linear_velocity(vec2(-speed, rand_range(-20, 20)))
	set_angular_velocity(rand_range(-1,1))