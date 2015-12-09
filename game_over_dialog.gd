
extends Panel

# speed of number count
const SPEED = 50

var scores = 0
var step = 0.0
var counter = 0

var score_label

# starts score count
func start_score_count():
	scores = get_node("/root/global").world.scores
	step = round(scores / SPEED)
	if step < 1:
		step = 1
	set_process(true)

func _process(delta):
	counter += step
	if counter > scores:
		counter = scores
		score_label.set_text(str(counter))
		set_process(false)
		return
	
	score_label.set_text(str(counter))

func _ready():
	score_label = get_node("Score")


