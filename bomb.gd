
extends RigidBody2D

var world
var global
var player
var player_body
var speed = 0
var min_speed = 0.5
var max_speed = 2
var anim

var explosion_time = 3
var explosion_delta = 0
var is_armed = false

func add_impulse(impulse):
	set_linear_velocity(impulse)

# arms bomb
func arm():
	is_armed = true
	anim.play("Armed")

# blow bomb
func kill():
	set_process(false)
	set_fixed_process(false)
	var ex = preload("res://explosion.scn").instance()
	world.add_child(ex)
	ex.explode(get_pos())
	queue_free()
	
func _fixed_process(delta):
	if global.is_gameover:
		set_fixed_process(false)
		return
		
	var pos = get_pos()
	var player_pos = player.get_pos()
	var player_body_pos = player_body.get_pos()
	var summ_pos = player_pos + player_body_pos
		
	if is_armed:
		if explosion_delta > explosion_time:
			kill()
			return
		else:
			anim.set_speed(explosion_delta * 3)
		explosion_delta += delta

	var dir = (pos - summ_pos).normalized()
	var x = dir.x * -speed * delta
	var y = dir.y * -speed * delta
	var vel = get_linear_velocity()
	vel += vec2(x, y)
	set_linear_velocity(vel)
	
	if pos.x < player_pos.x - 50:
		set_fixed_process(false)
		queue_free()

func _ready():
	global = get_node("/root/global")
	world = global.world
	player = global.player
	player_body = player.get_node("Player")
	anim = get_node("AnimationPlayer")
	speed = rand_range(min_speed, max_speed)
	set_fixed_process(true)
	set_angular_velocity(rand_range(-1,1))


func _on_TriggerZone_body_enter( body ):
	if body.get_name() == "Player":
		arm()
