extends KinematicBody2D

const SCORES_FOR_STAR = 100

const GRAV_ACCEL = 6
const ACCEL_Y = 10
const ACCEL_X = 3
const DEACCEL_X = 1
const MAX_ACC_X = 400

var accel_y = 0
var accel_x = 0

var view_width = 0
var width = 0

var global

# shields
var shield
var shield_anim
var shield_count = 3
var hit_delay = 0
var max_hit_delay = 1 # delay between hits

# fuel
const MAX_FUEL = 100
var fuel_count = MAX_FUEL

# some force
var force_impulse = vec2(0,0)

func game_over():
	var parent = get_parent()
	set_fixed_process(false)
	global.world.game_over()
	var ex = preload("res://explosion.scn").instance()
	global.world.add_child(ex)
	ex.explode(get_global_pos())
	parent.set_process(false)
	get_node("/root/global").is_gameover = true
	queue_free()

# kills player
func kill():
	global.hud.set_shields(0)
	game_over()

# adds external force
func add_impulse(impulse):
	force_impulse += impulse
	hit()

# hits player
func hit():
	shield_anim.play("down")
	shield_count -= 1
	global.hud.set_shields(shield_count)
	if shield_count < 1:
		kill()
	else:
		global.world.play_sound("hit")

func add_shield():
	if (shield_count < 3):
		shield_count += 1
		global.hud.set_shields(shield_count)

# adds fuel
func add_fuel():
	fuel_count = MAX_FUEL

# picks goods
func pick_goods(goods):
	if goods.is_star():
		global.world.scores += SCORES_FOR_STAR
	elif goods.is_shield():
		add_shield()
	elif goods.is_fuel():
		add_fuel()

func _fixed_process(delta):
	if is_colliding():
		var collider = get_collider()
		if collider != null && collider extends TileMap:
			kill()
			return
		if hit_delay > max_hit_delay:
			hit_delay = 0
			hit()
	
	hit_delay += delta
	
	var force = vec2(0, 0)
	var pos = get_pos()
	
	var fly = Input.is_action_pressed("ui_up")
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	
	if fly && fuel_count > 0:
		accel_y -= ACCEL_Y
		get_node("ThrustBottom").set_emitting(true)
		fuel_count -= delta
	else:
		get_node("ThrustBottom").set_emitting(false)
		accel_y += GRAV_ACCEL
		
	if right && fuel_count > 0:
		if pos.x < view_width - width / 2:
			get_node("ThrustLeft").set_emitting(true)
			accel_x += ACCEL_X
			fuel_count -= delta
	else:
		get_node("ThrustLeft").set_emitting(false)
	
	if left && fuel_count > 0:
		if pos.x > width / 2:
			get_node("ThrustRight").set_emitting(true)
			accel_x -= ACCEL_X
			fuel_count -= delta
		else:
			accel_x = 0
	else:
		get_node("ThrustRight").set_emitting(false)
	
	var s = sign(accel_x)
	accel_x = (abs(accel_x) - DEACCEL_X) * s
	
	if accel_x > MAX_ACC_X:
		accel_x = MAX_ACC_X
	
	if pos.x < width / 2:
		accel_x = 0
		pos.x = width / 2
		set_pos(pos)
	elif pos.x > view_width - width / 2:
		accel_x = 0
		pos.x = view_width - width / 2
		set_pos(pos)
	else:
		force.y = accel_y * delta
		force.x = accel_x * delta
		# applies force
		force += force_impulse
		move(force)
		force_impulse = force_impulse / 1.1
		
	# decreas fuel
	global.hud.set_fuel(fuel_count)

func _ready():
	global = get_node("/root/global")
	shield = get_node("Shield")
	shield_anim = get_node("ShieldAnim")
	width = get_node("Sprite").get_texture().get_size().width
	view_width = get_viewport_rect().size.width
	set_fixed_process(true)


