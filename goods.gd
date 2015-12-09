
extends Area2D

var view_size
var player
var player_body
var atom
var shield
var fuel
var items = []

const STAR = 0
const SHIELD = 1
const FUEL = 2

var good_type = STAR

func clear():
	for e in items:
		e.hide()

func set_as_star():
	good_type = STAR
	clear()
	atom.show()
	
func set_as_shield():
	good_type = SHIELD
	clear()
	shield.show()

func set_as_fuel():
	good_type = FUEL
	clear()
	fuel.show()

func is_star():
	return good_type == STAR
	
func is_shield():
	return good_type == SHIELD

func is_fuel():
	return good_type == FUEL

# picks star
func pick():
	player_body.pick_goods(self)
	dead()

# removes node
func dead():
	set_fixed_process(false)
	queue_free()

func _fixed_process(delta):
	var pos = get_pos()

	if pos.x < player.get_pos().x - 50:
		dead()

func _ready():
	player = get_node("/root/global").player
	player_body = player.get_node("Player")
	atom = get_node("Atom")
	shield = get_node("Shield")
	fuel = get_node("Fuel")
	
	items.append(atom)
	items.append(shield)
	items.append(fuel)
	
	set_fixed_process(true)

func _on_Place_body_enter( body ):
	if body extends KinematicBody2D:
		pick()
