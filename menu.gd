
extends Node2D

var global

func _ready():
	global = get_node("/root/global")
	get_node("MaxScores").set_text("High scores: " + str(global.scores))

func _on_NewGame_pressed():
	get_tree().change_scene("res://game_scene.scn")

func _on_SoundOff_toggled( pressed ):
	global.no_sound = pressed
