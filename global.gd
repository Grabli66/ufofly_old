extends Node

var world
var player
var camera
var hud
var tank_instance = null
var is_gameover = false
var scores = 0
var no_sound = false

func set_high_scores(s):
	if s > scores:
		scores = s
		# save scores
		var global_data = File.new()
		global_data.open("user://global.dat", File.WRITE)
		global_data.store_32(scores)
		global_data.close()
		
func _ready():
	var os_name = OS.get_name()
	if os_name != "android":
		var center = OS.get_screen_size() / 2	
		var view_size_half = OS.get_window_size() / 2
		OS.set_window_position(center - view_size_half)
	
	#loads high score
	var global_data = File.new()
	if !global_data.file_exists("user://global.dat"):
		return
	global_data.open("user://global.dat", File.READ)
	scores = global_data.get_32()
	global_data.close()