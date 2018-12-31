tool
extends "res://SCRIPTS/RoundProgress.gd"

# Constants
enum PLAYER_FACES { FACE_NORMAL, FACE_NEAR, FACE_HURT, FACE_MAX }
# Threshold between 0 and 1 of when Player should be alarmed
const THRESHOLD = 0.3

# Export values
export(Texture) var player_face setget set_player_face
export(int) var frame = 0 setget set_frame

# Instance members
onready var Face  = get_node("Face")
onready var Alarm = get_node("Alarm")
var FrameTimer = Timer.new()

# "Private" members
var current_face = FACE_NORMAL

########################
### Export functions ###
########################
func set_player_face(value):
	player_face = value
	if Face != null:
		Face.set_texture(value)

func set_frame(value):
	# Setting texture frame
	if 0 <= value && value < FACE_MAX:
		frame = value
		if Face != null:
			Face.set_frame(value)

######################
### Core functions ###
######################
func _ready():
	# Setting up Face Sprite
	Face.set_frame(FACE_NORMAL)

	# Setting FrameTimer
	FrameTimer.set_wait_time(0.5)
	FrameTimer.connect("timeout", self, "hurt", [false])
	add_child(FrameTimer)

func _draw():
	Face.set_position(center)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

	# Setting Alarm state
	if get_unit_value() <= THRESHOLD && current_face != FACE_NEAR:
		current_face = FACE_NEAR
		set_frame(current_face)
		Alarm.play()
	elif get_unit_value() > THRESHOLD && current_face != FACE_NORMAL:
		current_face = FACE_NORMAL
		set_frame(current_face)
		Alarm.stop()

###############
### Methods ###
###############
func hurt(begin=true):
	if begin:
		set_frame(FACE_HURT)
		FrameTimer.start()
	else:
		set_frame(current_face)

