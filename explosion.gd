
extends Area2D

var time = 0
var is_exploded = false
var explosion_power = 20
var world

# adds impulse to bodies
func add_impulse_to_bodies():
	var pos = get_global_pos()
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if !(b extends RigidBody2D) && !(b extends KinematicBody2D):
			continue
		if !b.has_method("add_impulse"):
			continue
		var body_pos = b.get_global_pos()
		var impulse = pos - body_pos
		var distance = pos.distance_to(body_pos)
		var force = (1 / distance) * explosion_power
		b.add_impulse(impulse * -force)

func _fixed_process(delta):
	time += delta
	if time > 0.1 && !is_exploded:
		get_node("Explosion").set_emitting(false)
		add_impulse_to_bodies()
		is_exploded = true
		
	if time > 0.5:
		queue_free()

# adds explosion
func explode(e):
	world.play_sound("explosion")
	set_pos(e)
	# shakes camera
	get_node("/root/global").camera.shake()
	

func _ready():
	world = get_node("/root/global").world
	set_fixed_process(true)
