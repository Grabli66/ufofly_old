
extends Area2D

# waits before burn
var wait_time = 0
var max_wait_time = 7

# burn time
var burn_time = 0
var max_burn_time = 3
var is_burning = false

var particles

#kills object
func kill_object(body):
	if body.has_method("kill"):
		body.kill()

func _fixed_process(delta):
	if wait_time > max_wait_time && !is_burning:
		set_enable_monitoring(true)
		particles.set_emitting(true)
		wait_time = 0
		burn_time = 0
		is_burning = true
	
	if burn_time > max_burn_time && is_burning:
		set_enable_monitoring(false)
		particles.set_emitting(false)
		burn_time = 0
		wait_time = 0
		is_burning = false
	
	wait_time += delta
	burn_time += delta

func _ready():
	particles = get_node("Vulkan")
	max_wait_time = rand_range(4, 10)
	max_burn_time = rand_range(3, 6)
	set_fixed_process(true)

func _on_Place_body_enter( body ):
	kill_object(body)
