
extends Area2D

const GUN_SPEED = 0.5
const MOVE_SPEED = 20
var global
var player_body
var gun
var head
var bullet
var move_anim
var fire_from
var fire_to
var fire_anim

var is_aiming = false
var max_fire_wait = 3
var fire_wait = 0

var engine_emitter
var is_move = false
var prev_sign = 0

func kill_object(body):
	if body.has_method("kill"):
		body.kill()

func start_aim():
	is_aiming = true
	set_fixed_process(true)

func stop_aim():
	is_aiming = false
	is_move = false
	move_anim.play("idle")
	engine_emitter.set_emitting(false)
	
# stops when changed round
func stop():
	get_node("Look").set_enable_monitoring(false)
	stop_aim()

# fires
func fire():
	global.world.play_sound("cannon")
	fire_anim.play("fire")
	var nb = bullet.instance()
	global.world.add_child(nb)
	nb.fire_from_to(fire_from.get_global_pos(), fire_to.get_global_pos())

func _fixed_process(delta):
	var pos = get_pos()
	
	if is_aiming:
		var player_pos = player_body.get_global_pos()
		var ang = gun.get_angle_to(player_pos) - deg2rad(90)
		var dir = (pos - player_pos).normalized()
		
		var sig = sign(dir.x)
		if (prev_sign != sig):
			is_move = false
			prev_sign = sig
		
		if sig > 0 && !is_move:
			is_move  = true
			move_anim.play("move_left")
			engine_emitter.set_emitting(true)
			
		elif sig < 0 && !is_move:
			is_move  = true
			move_anim.play("move_right")
			engine_emitter.set_emitting(true)
		
		pos.x -= dir.x * delta * MOVE_SPEED
		set_pos(pos)
		
		var rot = rad2deg(gun.get_rot())
		if rot < 90:
			head.set_frame(0)
		else:
			head.set_frame(1)
		
		gun.rotate(ang * delta * GUN_SPEED)
		
		if fire_wait > max_fire_wait:
			fire()
			fire_wait = 0
		
		fire_wait += delta
	
	if pos.x < global.player.get_pos().x - 50:
		queue_free()
		global.tank_instance = null

func _ready():
	global = get_node("/root/global")
	player_body = global.player.get_node("Player")
	gun = get_node("Gun")
	head = get_node("Head")
	fire_from = get_node("Gun/FireFrom")
	fire_to = get_node("Gun/FireTo")
	fire_anim = get_node("FireAnim")
	bullet = preload("res://bullet.scn")
	move_anim = get_node("MoveAnim")
	engine_emitter = get_node("EngineEmitter")

func _on_Place_body_enter( body ):
	kill_object(body)

func _on_Look_body_enter( body ):
	if body.get_name() != "Player":
		return
	start_aim()


func _on_Look_body_exit( body ):
	if body.get_name() != "Player":
		return
	stop_aim()
