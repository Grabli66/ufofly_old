
extends CanvasLayer

var is_paused = false
var shield
# tween for game over dialog
var tween
var game_over_dialog
# fuel tank
var fuel
# bubbles in fuel tank
var bubbles

var pause_button

# sets shield sprites
func set_shields(count):
	if count > 3:
		count = 3
	elif count < 0:
		count = 0
	
	shield.set_frame(3 - count)

# sets fuel
func set_fuel(count):
	fuel.set_scale(vec2(1, count / 100))
	bubbles.set_param(Particles2D.PARAM_LINEAR_VELOCITY, count * (120 / 100))

# shows game over dialog
func show_game_over():
	game_over_dialog.show()
	# fix pos
	tween.interpolate_method(game_over_dialog, "set_pos", Vector2(300,-300), Vector2(300, 150), 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	game_over_dialog.start_score_count()

func _ready():
	get_node("/root/global").hud = self
	tween = get_node("GameOverDialog/Tween")
	game_over_dialog = get_node("GameOverDialog")
	game_over_dialog.hide()
	shield = get_node("ItemPanel/Shield")
	fuel = get_node("ItemPanel/FuelTank/Fuel")
	bubbles = get_node("ItemPanel/FuelTank/Bubbles")
	pause_button = get_node("GamePanel/Pause")

func _on_Again_pressed():
	get_tree().change_scene("res://game_scene.scn")

func _on_Back_pressed():
	get_tree().change_scene("res://menu_scene.scn")

func _on_Pause_pressed():
	is_paused = !is_paused
	get_tree().set_pause(is_paused)

func _on_StartGame_pressed():
	get_node("StartGameDialog").hide()
	get_tree().set_pause(false)
	pause_button.set_pause_mode(Node2D.PAUSE_MODE_PROCESS)
