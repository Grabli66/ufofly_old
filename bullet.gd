
extends Area2D

const MAX_AFTER_FIRE_TIME = 1
const MAX_LIFE_TIME = 10
var world
var speed = 100
var life_time = 0
var after_fire_time = 0
var direction

func add_impulse(impulse):
	boom()
	
func kill():
	boom()

func boom():
	var ex = preload("res://explosion.scn").instance()
	world.add_child(ex)
	ex.explode(get_global_pos())
	queue_free()

# launches bullet to target
func fire_from_to(start_pos, target):
	set_pos(start_pos)
	look_at(target)
	direction = target - start_pos
	set_fixed_process(true)

func _fixed_process(delta):
	var pos = get_pos() + direction.normalized() * speed * delta
	set_pos(pos)

	if life_time > MAX_LIFE_TIME:
		boom()
	life_time += delta
	after_fire_time += delta

func _ready():
	world = get_node("/root/global").world

func _on_Place_body_enter( body ):
	if (body extends TileMap):
		if after_fire_time > MAX_AFTER_FIRE_TIME:
			boom()
	else:
		boom()


func _on_Place_area_enter( area ):
	if area.has_method("is_for_collision"):
		boom()
