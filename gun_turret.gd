extends Area2D

var world
var player
var player_body
var turret
var turret_anim
var fire_anim
var bullet
var bullet_place
var bullet_aim
var is_aiming = false
var rotate_speed = 0.5

# starts aim
func start_aim():
	turret_anim.play("aim")
	set_fixed_process(true)
	is_aiming = true
	
# stops aim
func stop_aim():
	turret_anim.play("idle")
	is_aiming = false

# fires
func fire():
	world.play_sound("cannon")
	fire_anim.play("fire")
	var nb = bullet.instance()
	world.add_child(nb)
	nb.fire_from_to(bullet_place.get_global_pos(), bullet_aim.get_global_pos())

func _fixed_process(delta):
	var pos = get_pos()
	
	if is_aiming:
		var player_pos_sum = player.get_pos() + player_body.get_pos()
		var ang = turret.get_angle_to(player_pos_sum)
		turret.rotate(ang*delta*rotate_speed)
	
	if pos.x < player.get_pos().x - 50:
		queue_free()

func _ready():
	world = get_node("/root/global").world
	player = get_node("/root/global").player
	player_body = player.get_node("Player")
	turret = get_node("Turret")
	turret_anim = get_node("TurretAnim")
	fire_anim = get_node("FireAnim")
	bullet = preload("res://bullet.scn")
	bullet_place = get_node("Turret/BulletPlace")
	bullet_aim = get_node("Turret/BulletAim")

func _on_Place_body_enter( body ):
	if body.get_name() == "Player":
		start_aim()

func _on_Place_body_exit( body ):
	if body.get_name() == "Player":
		stop_aim()

func _on_TurretAnim_finished():
	if is_aiming:
		fire()

func _on_FireAnim_finished():
	if is_aiming:
		start_aim()
