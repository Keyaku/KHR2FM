extends Node


# Constants
enum PAUSE_CONTROLS { PAUSE_BUTTON_CONTINUE, PAUSE_BUTTON_SKIP }

# Instance members
onready var Options = get_node("Options")

######################
### Core functions ###
######################
func _ready():
	hide()
	_set_availability(PAUSE_BUTTON_SKIP, true)

	# Connecting pause-behavior signals
	KHR2.connect("toggle_pause", self, "_pressed_pause")
	SceneLoader.connect("scene_was_pushed", self, "_set_availability", [PAUSE_BUTTON_SKIP, false])

	# Connecting button signals
	for i in range(0, Options.get_child_count()):
		var button = Options.get_child(i)
		button.connect("pressed", self, "_pause_controls", [i])

#######################
### Signal routines ###
#######################
func _set_availability(button_idx, value):
	var button = get_node("Options").get_child(button_idx)
	button.set_disabled(value)

func _pressed_pause():
	set_hidden(!get_tree().is_paused()) # Showing screen

	if get_tree().is_paused():
		Options.get_child(0).grab_focus()
		# TODO: play SE
	else:
		pass # TODO: play dismissal SE

func _pause_controls(button_idx):
	KHR2.pause_game()
	if button_idx == PAUSE_BUTTON_SKIP:
		if SceneLoader.is_loaded():
			SceneLoader.show_next_scene(true)
		else:
			SceneLoader.load_next_scene()
