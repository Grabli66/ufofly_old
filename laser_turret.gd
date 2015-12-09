extends Area2D

var world
var player
var player_body
var turret
var turret_anim
var detail_anim
var beam
var beam_particles
var ray_cast
var is_aiming = false
var rotate_speed = 0.1
var fire_delay = 0
var is_fire = false
var sound_id = -1
const MAX_FIRE_DELAY = 3

var beam_hit_delay = 0.7
var beam_hit = beam_hit_delay

# starts aim
func start_aim():
	turret_anim.play("aim")
	detail_anim.play("aim")
	set_fixed_process(true)
	is_aiming = true
	
# stops aim
func stop_aim():
	#if sound_id != -1:
	#	world.stop_sound(sound_id)
	is_fire = false
	fire_delay = 0
	turret_anim.play("idle")
	detail_anim.play("idle")
	is_aiming = false
	beam.hide()
	beam_particles.hide()
	ray_cast.set_enabled(false)

# fires
func fire():
	#sound_id = world.play_sound("laser")
	is_fire = true
	beam.show()
	beam_particles.show()
	ray_cast.set_enabled(true)

func _fixed_process(delta):
	var pos = get_pos()

	if is_aiming:
		var player_pos_sum = player.get_pos() + player_body.get_pos()
		var ang = turret.get_angle_to(player_pos_sum)
		turret.rotate(ang*delta*rotate_speed)
		if ray_cast.is_colliding():
			if beam_hit > beam_hit_delay:
				var collider = ray_cast.get_collider()
				if collider.has_method("hit"):
					collider.hit()
				beam_hit = 0
			beam_hit += delta
		
		if fire_delay > MAX_FIRE_DELAY && !is_fire:
			fire()
		
		fire_delay += delta
	
	if pos.x < player.get_pos().x - 50:
		set_fixed_process(false)
		queue_free()

func _ready():
	world = get_node("/root/global").world
	player = get_node("/root/global").player
	player_body = player.get_node("Player")
	beam = get_node("Turret/Beam")
	beam_particles = get_node("Turret/BeamParticles")
	ray_cast = get_node("Turret/RayCast")
	turret = get_node("Turret")
	turret_anim = get_node("TurretAnim")
	detail_anim = get_node("DetailAnim")
	beam.hide()
	beam_particles.hide()

func _on_Place_body_enter( body ):
	if body.get_name() == "Player":
		start_aim()

func _on_Place_body_exit( body ):
	if body.get_name() == "Player":
		stop_aim()
