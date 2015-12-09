extends Camera2D

const SHAKE_SIZE = 2
const SHAKE_TIME = 1
var time = 0

var player
var world
var is_shake = false
var is_follow = true

func shake():
	time = 0
	is_shake = true
	
# follows in vertical
func follow_vert(e):
	is_follow = e

func _process(delta):
	if is_shake:
		time += delta
		set_offset(vec2(rand_range(-SHAKE_SIZE, SHAKE_SIZE), rand_range(-SHAKE_SIZE, SHAKE_SIZE)))
		if time > SHAKE_TIME:
			is_shake = false
		
	var pos = player.get_pos()
	pos.x += world.view_size.width / 2
	if !is_follow:
		pos.y = world.last_center_cell * world.TILEMAP_SIZE
	set_pos(pos) 

func _ready():
	randomize()
	world = get_node("/root/World")
	player = get_node("/root/World/Move")
	get_node("/root/global").camera = self
	set_process(true)


