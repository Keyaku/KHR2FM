tool
extends "DynamicBar.gd"

# Signals
signal begin_rage
signal end_rage

# Constants
const STATE_NORMAL = false
const STATE_RAGE   = true
const MP_FG = [
	preload("res://ASSETS/GFX/Game/Battle/HUD/Player/MP-bar.png"),
	preload("res://ASSETS/GFX/Game/Battle/HUD/Player/MP-recover.png"),
]
const MP_COLORS = [
	Color(0.46, 0.41, 0.92),
	Color(0.88, 0.41, 0.89),
]

# Export values
export(bool) var rage_state = false setget set_state

# Instance members
onready var MP_label = get_node("Label")
var decrement = Timer.new()

# "Private" members
var initial_pos

########################
### Export functions ###
########################
func set_state(value):
	rage_state = value
	var state = int(value)

	# Changing StyleBox texture
	var sbx = get_stylebox("fg")
	sbx.set_texture(MP_FG[state])
	add_style_override("fg", sbx)

	# Changing label color
	if MP_label != null:
		MP_label.add_color_override("font_color", MP_COLORS[state])

######################
### Core functions ###
######################
func _ready():
	# Setting MP bar's initial position (for SlideAnim)
	initial_pos = OS.get_video_mode_size()
	initial_pos.y = get_global_position().y  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

	# Runtime settings
	if not get_tree().is_editor_hint():
		# Setting rage mode timer
		var recovery_rate = 0.3
		# TODO: multiply by modifiers that increase/decrease this rate
		decrement.set_wait_time(recovery_rate)
		decrement.set_one_shot(false)
		decrement.connect("timeout", self, "_decrementing")
		add_child(decrement)

		# Setting up automatic switching upon reaching 0
		connect("zero", self, "switch_state")

func _display():
	var final_pos = get_global_position()  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	set_global_position(initial_pos)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	SlideAnim.stop_all()
	SlideAnim.interpolate_method(
		self, "set_global_pos",
		initial_pos, final_pos,
		1, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	SlideAnim.start()

#######################
### Signal routines ###
#######################
func switch_state():
	set_state(!rage_state)
	_display()
	if rage_state:
		set_value(get_max())
		decrement.start()
		emit_signal("begin_rage")
	else:
		decrement.stop()
		emit_signal("end_rage")

func _decrementing():
	set_value(get_value()-1)

###############
### Methods ###
###############

