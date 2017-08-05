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
	Color(0.88, 0.41, 0.89),
	Color(0.46, 0.41, 0.92)
]

# Export values
export(bool) var rage_state = false setget set_state

# Instance members
onready var MP_label = get_node("Label")
var decrement = Timer.new()

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

#######################
### Signal routines ###
#######################
func switch_state():
	set_state(!rage_state)
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
