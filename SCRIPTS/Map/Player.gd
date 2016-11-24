extends KinematicBody2D

# Constants
const MOTION_SPEED = 300 # Pixels/second

# Instance members
onready var Anims     = get_node("anims")
onready var Character = get_node("Character")

# "Private" members

######################
### Core functions ###
######################
func _ready():
	set_fixed_process(true)

# Totally stolen from isometric example but eh
func _fixed_process(delta):
	# Grabbing Input
	var left  = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var up    = Input.is_action_pressed("ui_up")
	var down  = Input.is_action_pressed("ui_down")

	animate_character(up, down, left, right)
	move_character(up, down, left, right, delta)

func _input(event):
	pass

###############
### Methods ###
###############
func animate_character(up, down, left, right):
	var current_anim = Anims.get_current_animation()
	var new_anim = current_anim

	# Order is key: first, the multiple inputs; then, the single ones
	if up && right:
		new_anim = "up_right"
	elif up && left:
		new_anim = "up_left"
	elif down && right:
		new_anim = "down_right"
	elif down && left:
		new_anim = "down_left"
	elif up:
		new_anim = "up"
	elif down:
		new_anim = "down"
	elif left:
		new_anim = "left"
	elif right:
		new_anim = "right"

	# If not moving at all
	if not up && not down && not left && not right:
		Anims.stop()
		if   new_anim == "up":
			Character.set_frame(27)
		elif new_anim == "down":
			Character.set_frame(0)
		elif new_anim == "left":
			Character.set_frame(9)
		elif new_anim == "right":
			Character.set_frame(18)
		elif new_anim == "up_left":
			Character.set_frame(54)
		elif new_anim == "up_right":
			Character.set_frame(63)
		elif new_anim == "down_left":
			Character.set_frame(54)
		elif new_anim == "down_right":
			Character.set_frame(45)
	else:
		if new_anim != current_anim || !Anims.is_playing():
			Anims.play(new_anim)

func move_character(up, down, left, right, delta=0):
	var motion = Vector2()
	if up:
		motion += Vector2(0, -1)
	if down:
		motion += Vector2(0, 1)
	if left:
		motion += Vector2(-1, 0)
	if right:
		motion += Vector2(1, 0)

	motion = motion.normalized() * MOTION_SPEED * delta
	motion = move(motion)

	# Make character slide nicely through the world
	# tl;dr slides when collisions detected
	var slide_attempts = 4
	while is_colliding() and slide_attempts > 0:
		motion = get_collision_normal().slide(motion)
		motion = move(motion)
		slide_attempts -= 1