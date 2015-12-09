
extends Node2D

var global
# sound player
var sound

# viewport size
var view_size

# for scores
var scores_label
var scores = 0
const SCORE_TIME = 0.5
var score_time = 0

# round types
const CAVE_ROUND = 0
const ASTEROIDS = 1
const TECH = 2

# current round type
var round_type = ASTEROIDS
var round_time = 0
var next_round_time = 0
var min_round_time = 50
var max_round_time = 150
var current_frame = 0
var current_frame_type = round_type
var next_frame_type = round_type
var round_number = 0

const TILEMAP_SIZE = 32
var tilemaps = []
var cur_map_index = 0
var w_cell_count = 0
var h_cell_count = 0

# for cave generation
var min_cor_height = 3
var max_cor_height = 7
var max_path_offset = 0.5
var max_path_ampl = 0.5
var center_cell = 0
var last_center_cell = 0

# for asteroids generation
const ASTEROID_ADD_TIME = 1
var asteroid_add_time = 0
var max_add_asteroids = 1
var max_bombs_count = 2

# enemies
var asteroid
var bomb
var gun_turret
var laser_turret
var vulkan
var press

# tank
var tank
# chance of tank place
var tank_persent = 70

# player node
var player

# tools items
var good_item
var star_percent = 30 # persent for star place
var fuel_percent = 50 # persent for fuel place
var shield_percent = 30 # persent for shield place

# for input pause
var pressed_time = 0
const PRESSED_TIME = 1

func game_over():
	# sets high score
	get_node("/root/global").set_high_scores(scores)
	# shows game over dialog
	global.hud.show_game_over()
	# stops process
	set_process(false)

func _process(delta):
	# adds score
	if score_time > SCORE_TIME:
		score_time = 0
		scores += 1
		scores_label.set_text(str(scores))
	score_time += delta

	# swaps tilemaps
	var frame = floor(player.get_pos().x / view_size.width)
	if frame > current_frame:
		current_frame_type = next_frame_type
		change_states()
		current_frame = frame
		gen_next_frame()
		
	# adds enemies
	gen_enemies(delta)
	
	round_time += delta
	if round_time > next_round_time:
	#if Input.is_action_pressed("ui_accept") && pressed_time > PRESSED_TIME:
		round_type = get_next_round_type()
		round_time = 0
		next_round_time = get_next_round_time()
		round_number += 1
		pressed_time = 0
		
		#stops tank
		if global.tank_instance != null:
			global.tank_instance.stop()
		
		#print(round_type)
		
	pressed_time += delta

# checks position not used
func check_place(cell_pos, used_cells):
	for e in used_cells:
		if (round(cell_pos.x) == round(e.x)) && (round(cell_pos.y) == round(e.y)):
			return false
	return true

# place one good in free place
func place_good(map_pos, used_cells, good_type):
	var top = floor(center_cell - h_cell_count / 2)
	var bottom = top + h_cell_count
	var cell_x = rand_range(3, w_cell_count)
	var cell_y = rand_range(top + 2, bottom - 2)
	
	while(!check_place(vec2(cell_x, cell_y), used_cells)):
		cell_x = rand_range(3, w_cell_count)
		cell_y = rand_range(top + 2, bottom - 2)
		
	var pos_x = map_pos.x + cell_x * TILEMAP_SIZE
	var pos_y = cell_y * TILEMAP_SIZE
	
	var item = good_item.instance()
	add_child(item)
	
	if good_type == item.STAR:
		item.set_as_star()
	elif good_type == item.SHIELD:
		item.set_as_shield()
	elif good_type == item.FUEL:
		item.set_as_fuel()
		
	item.set_pos(vec2(pos_x, pos_y))

# adds goods : star, shield, fuel
func place_goods(map_pos, used_cells):
	var top = floor(center_cell - h_cell_count / 2)
	var bottom = top + h_cell_count
	
	var item = good_item.instance()
	
	if star_percent > rand_range(0, 100):
		place_good(map_pos, used_cells, item.STAR)
	
	if shield_percent > rand_range(0, 100):
		place_good(map_pos, used_cells, item.SHIELD)
	
	if fuel_percent > rand_range(0, 100):
		place_good(map_pos, used_cells, item.FUEL)

# change some states like camera drag
func change_states():
	if current_frame_type == ASTEROIDS || current_frame_type == TECH:
		global.camera.follow_vert(false)
	else:
		global.camera.follow_vert(true)
	pass

func get_next_round_type():
	var ro = abs(round(rand_range(-1, 3)))
	while ro == round_type:
		ro = abs(round(rand_range(-1, 3)))
	
	if ro > 2:
		ro = 2
	return ro
	#return TECH

func get_next_round_time():
	#return 30
	return round(rand_range(min_round_time, max_round_time))

# generates next frame for game
func gen_next_frame():
	swap_tilemaps()
	var tilemap = tilemaps[cur_map_index]
	pos_tilemaps()
	if round_type == CAVE_ROUND:
		gen_cave_frame(tilemap)
	elif round_type == ASTEROIDS:
		gen_asteroids_frame(tilemap)
	elif round_type == TECH:
		gen_tech_frame(tilemap)

func next_path_offset():
	return round(rand_range(-max_path_offset, max_path_offset))

func next_cor_height():
	return round(rand_range(min_cor_height, max_cor_height))

# generates tech frame
func gen_tech_frame(tilemap):
	next_frame_type = TECH
	last_center_cell = center_cell
	tilemap.clear()
	var tilemap_pos = tilemap.get_pos()

	var tower_count = rand_range(2, 4)
	var top = floor(center_cell - h_cell_count / 2)
	var bottom = top + h_cell_count
	var used_cells = [] # for place goods
	
	# creates tower
	var period = round(w_cell_count / tower_count)
	for i in range(0, tower_count):
		var pos_x = period * i + 1
		var pos_y = round(rand_range(top+3, bottom-3) - 1)
		
		# add turret
		var nt = null
		if (rand_range(-1,1) > 0):
			nt = gun_turret.instance()
		else:
			nt = laser_turret.instance()
		var tower_pos = vec2(0,0)
		tower_pos.x = tilemap_pos.x + (pos_x + 1.5) * TILEMAP_SIZE;
		tower_pos.y = tilemap_pos.y + (pos_y + 1.5) * TILEMAP_SIZE;
		nt.set_pos(tower_pos)
		add_child(nt)
		
		# add turret place
		for x in range(0, 3):
			for y in range(0, 3):
				var ux = pos_x+x
				var uy = pos_y+y
				tilemap.set_cell(ux, uy, 4)
				used_cells.append(vec2(ux, uy))
		
		var sgn = 0
		# has tail
		if (rand_range(0, 100) > 10):
			sgn = sign(rand_range(-1,1))
			if pos_y - top < 8:
				sgn = -1
			elif bottom - pos_y < 8:
				sgn = 1
			
			for y in range(0, h_cell_count - pos_y * sgn):
				var ux = pos_x + 1
				var uy = pos_y + y * (sgn)
				tilemap.set_cell(ux, uy, 4)
				used_cells.append(vec2(ux, uy))
		
		# add press
		var np = press.instance()
		var press_y = 0
		
		if sgn > 0:
			press_y = tilemap_pos.y + top * TILEMAP_SIZE
			np.rotate(deg2rad(180))
		else:
			press_y = tilemap_pos.y + (bottom + 1) * TILEMAP_SIZE
			
		var press_x = tilemap_pos.x + (pos_x + 1.5) * TILEMAP_SIZE;
		np.set_pos(vec2(press_x, press_y))
		add_child(np)
	
	gen_walls(tilemap)
	# place goods
	place_goods(tilemap_pos, used_cells)

# generates cave frame
func gen_cave_frame(tilemap):
	next_frame_type = CAVE_ROUND
	last_center_cell = center_cell
	tilemap.clear()
	var tilemap_pos = tilemap.get_pos()
	
	var vulkan_count = rand_range(2, 3)
	var down_vulkan_poses = []	# for down vulkans
	var up_vulkan_poses = []	# for up vulkans
	var used_cells = [] # for place goods
	
	var off = rand_range(-max_path_ampl, max_path_ampl)
	for i in range(0, w_cell_count):
		center_cell += off
		var path = center_cell + next_path_offset()
		var ch = next_cor_height()
		
		var top_path = path - ch
		var bot_path = path + ch
		
		for k in range(0, 20):
			if k == 0:
				up_vulkan_poses.append(vec2(i, top_path))
				down_vulkan_poses.append(vec2(i, bot_path))
			
			var ytop = top_path - k
			var ybottom = bot_path + k
			
			tilemap.set_cell(i, ytop, 3)
			tilemap.set_cell(i, ybottom, 3)
			used_cells.append(vec2(i, ytop))
			used_cells.append(vec2(i, ybottom))
	
	# place goods
	place_goods(tilemap_pos, used_cells)
	
	# places vulkans
	for i in range(0, vulkan_count):
		var nv = vulkan.instance()
		var pos = vec2(0,0)
		if (rand_range(-1,1) > 0):
			var index = round(rand_range(0, down_vulkan_poses.size()-1))
			pos = down_vulkan_poses[index]
			pos.x = (pos.x + 0.5) * TILEMAP_SIZE + tilemap_pos.x
			pos.y = pos.y * TILEMAP_SIZE + tilemap_pos.y
			nv.set_pos(pos)
		else:
			var index = round(rand_range(0, up_vulkan_poses.size()-1))
			pos = up_vulkan_poses[index]
			pos.x = (pos.x + 0.5) * TILEMAP_SIZE + tilemap_pos.x
			pos.y = pos.y * TILEMAP_SIZE + tilemap_pos.y
			nv.rotate(deg2rad(180))
			nv.set_pos(pos)
		add_child(nv)

# generates top and bottom wals
func gen_walls(tilemap):
	for i in range(0, w_cell_count):
		var top = floor(center_cell - h_cell_count / 2)
		var bottom = top + h_cell_count
		tilemap.set_cell(i, top, 2)
		tilemap.set_cell(i, bottom, 1)
		
		for k in range(0, 10):
			tilemap.set_cell(i, top - k - 1, 2)
			tilemap.set_cell(i, bottom + k + 1, 1)

# generates asteroid frame
func gen_asteroids_frame(tilemap):
	next_frame_type = ASTEROIDS
	last_center_cell = center_cell
	tilemap.clear()
	gen_walls(tilemap)
	
	# place enemies
	var top = floor(center_cell - h_cell_count / 2)
	var bottom = top + h_cell_count
	
	# place nothing when starts game
	if current_frame == 0:
		return
	
	# adds bombs
	var map_pos = tilemap.get_pos()
	var bomb_count = round(rand_range(1, max_bombs_count))
	for i in range(0, bomb_count):
		var pos_x = map_pos.x + rand_range(3, w_cell_count) * TILEMAP_SIZE
		var pos_y = rand_range(top + 2, bottom - 2) * TILEMAP_SIZE
		var nb = bomb.instance()
		nb.set_pos(vec2(pos_x, pos_y))
		add_child(nb)
		
	# add tank
	if global.tank_instance == null:
		if (rand_range(0, 100) < tank_persent):
			global.tank_instance = tank.instance()
			global.tank_instance.set_pos(vec2(map_pos.x + TILEMAP_SIZE*2, bottom * TILEMAP_SIZE - TILEMAP_SIZE/3))
			add_child(global.tank_instance)
	
	# places goods
	place_goods(map_pos, [])

# generates asteroids then asteroid round
func gen_asteroids_enemies(delta):
	if asteroid_add_time < ASTEROID_ADD_TIME:
		asteroid_add_time += delta
		return

	asteroid_add_time = 0
	var tp = player.get_pos()
	var x = tp.x
	var top = (center_cell * TILEMAP_SIZE - view_size.height / 2) + 50
	var bottom = (center_cell * TILEMAP_SIZE + view_size.height / 2) - 50
	
	for i in range(0, round(rand_range(0, max_add_asteroids))):
		var new_asteroid = asteroid.instance()
		new_asteroid.set_pos(vec2(x + view_size.width + 20, rand_range(top, bottom)))
		add_child(new_asteroid)

# generates enemies
func gen_enemies(delta):
	if (current_frame_type == ASTEROIDS && next_frame_type == ASTEROIDS):
		gen_asteroids_enemies(delta)

# spaws tilemap indexes
func swap_tilemaps():
	if cur_map_index == 0:
		cur_map_index = 1
	else:
		cur_map_index = 0

# poses tilemaps
func pos_tilemaps():
	var pos = vec2(view_size.width * (current_frame + 1), 0)
	if cur_map_index == 0:
		tilemaps[0].set_pos(pos)
	else:
		tilemaps[1].set_pos(pos)

# inits times
func init_times():
	next_round_time = get_next_round_time()

# init first frames
func init_frames():
	gen_asteroids_frame(tilemaps[1])
	gen_asteroids_frame(tilemaps[0])
	#gen_tech_frame(tilemaps[1])
	#gen_tech_frame(tilemaps[0])

func play_sound(name):
	if !global.no_sound:
		return sound.play(name)

func stop_sound(id):
	if !global.no_sound:
		sound.stop(id)

func _ready():
	randomize()
	sound = get_node("Sound")
	view_size = get_viewport_rect().size
	
	# init global
	global = get_node("/root/global")
	global.world = self
	global.is_gameover = false
	
	# inits times to place items
	init_times()

	# add tilemaps and sets its pos
	tilemaps.append(get_node("TileMap1"))
	tilemaps.append(get_node("TileMap2"))
	pos_tilemaps()
	
	w_cell_count = floor(view_size.x / TILEMAP_SIZE)
	h_cell_count = floor(view_size.y / TILEMAP_SIZE)
	center_cell = (view_size.y / TILEMAP_SIZE) / 2
	last_center_cell = center_cell
	scores_label = get_node("Hud/ItemPanel/Scores")
	
	# loads items and enemies
	player = get_node("Move")
	asteroid = preload("res://asteroid.scn")
	bomb = preload("res://bomb.scn")
	gun_turret = preload("res://gun_turret.scn")
	laser_turret = preload("res://laser_turret.scn")
	good_item = preload("res://goods.scn")
	vulkan = preload("res://vulkan.scn")
	press = preload("res://press.scn")
	tank = preload("res://tank.scn")
	global.tank_instance = null
	
	# init frames
	init_frames()
	change_states()
	
	set_process(true)
	get_tree().set_pause(true)