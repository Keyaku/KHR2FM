extends Node

# Export values
# TODO

# Signals
signal no_more_lines

# Constants
const PATH_MUGSHOTS = "res://GAME/SCENES/Dialogue/Mugshots/"
const TextScroll = preload("res://GAME/SCRIPTS/TextScroll.gd")

onready var ALL_ANCHORS = [
	get_node("Bubble/Speech/anchor_left"),
	get_node("Bubble/Speech/anchor_right")
]
onready var ALL_BUBBLES = [
	get_node("Bubble/Narrator"),
	get_node("Bubble/Speech")
]

# Instance members
var Bubble = {
	"text"    : null,
	"node"    : null,
	"anchor"  : null,
	"anims"   : {
		"fadein"  : null,
		"fadeout" : null
	}
}
var ConfirmKey = {
	"SE" : {
		"name" : null,
		"node" : null
	},
	"anims"    : null,
	"icon"     : null
}
var Mugshot = {
	"side"    : false,  # false = left, true = right
	"specify" : false,
	"nodes"   : [null, null]
}
var CurrentSpeaker = {
	"count"   : 0,
	"name"    : null
}

# Global values
var dialogue_context = ""
var text_collection = {}

######################
### Core functions ###
######################
func _ready():
	# Filling bubble
	Bubble.node = _get_bubble(0)
	Bubble.anchor = _get_anchor()
	Bubble.anchor.show()
	Bubble.anims.fadein = get_node("Bubble/FadeIn")
	Bubble.anims.fadeout = get_node("Bubble/FadeOut")

	# Preparing confirm key
	ConfirmKey.icon = get_node("MiniKeyblade")
	ConfirmKey.anims = get_node("MiniKeyblade/anims")

	# Setting text-related data
	Bubble.text = TextScroll.new()
	Bubble.text.set_name("TextScroll")
	Bubble.text.set_text_node(get_node("TextBox"))
	add_child(Bubble.text)

	# Connecting signals
	Bubble.anims.fadein.connect("finished", self, "_get_line")
	Bubble.anims.fadeout.connect("finished", self, "emit_signal", ["no_more_lines"])
	Bubble.text.connect("started", self, "_hide_keyblade")
	Bubble.text.connect("finished", self, "_show_keyblade")
	Bubble.text.connect("cleared", self, "_next_line")

	# Setting default SE
	set_SE()

func _input(event):
	# Pressed, non-repeating Input check
	if event.is_pressed() && !event.is_echo():
		if event.is_action("enter"):
			Bubble.text.confirm()
	# Pressed, repeating Input check
	elif event.is_pressed() && event.is_echo():
		if event.is_action("fast-forward"):
			Bubble.text.confirm()

# Some wrappers
func _get_bubble(type):
	return ALL_BUBBLES[type]

func _get_anchor():
	return ALL_ANCHORS[int(Mugshot.side)]

func _switch_side():
	Mugshot.side = !Mugshot.side
	# Setting anchor
	Bubble.anchor.hide()
	Bubble.anchor = _get_anchor()
	Bubble.anchor.show()

func _switch_mugshot(mugshot, pos):
	if mugshot == null:
		return

	var i = int(Mugshot.side)

	# if it contains a node but is the same as argument
	if Mugshot.nodes[i] == mugshot:
		return
	# if we need to switch a previously stored mugshot
	elif Mugshot.nodes[i] != null:
		# TODO: SlideOut animation
		Mugshot.nodes[i].hide()

	# Make the switch
	Mugshot.nodes[i] = mugshot
	Mugshot.nodes[i].set_flip_h(Mugshot.side)
	# Set its position
	Mugshot.nodes[i].set_pos(pos[i])
	# Show it
	Mugshot.nodes[i].show()
	# TODO: SlideIn animation

func _has_speaker():
	return (CurrentSpeaker.name != null && !CurrentSpeaker.name.empty()
		&& Bubble.node == _get_bubble(1))

func _open_dialogue():
	# Revealing current bubble setup
	Bubble.anims.fadein.play(Bubble.node.get_name())

func _close_dialogue():
	set_process_input(false)

	# Cleaning bubble
	Bubble.anims.fadeout.play(Bubble.node.get_name())
	_hide_keyblade()

func _translate():
	var name = ""
	if !CurrentSpeaker.name.empty():
		name = CurrentSpeaker.name + "_"

	# ID format: (CHARACTER_)GAME_CONTEXT_COUNT
	# ID example 1: INTRO_FATHERSON_00
	# ID example 2: KIRYOKU_INTRO_FATHERSON_00
	var index = text_collection[CurrentSpeaker.name].index
	var lineID = name + dialogue_context + "_%02d" % index

	# Incrementing index
	text_collection[CurrentSpeaker.name].index += 1

	return tr(lineID)

#######################
### Signal routines ###
#######################
func _show_keyblade():
	ConfirmKey.icon.show()
	ConfirmKey.anims.play("Keyblade Hover")

func _hide_keyblade():
	ConfirmKey.anims.stop()
	ConfirmKey.icon.hide()

func _get_line():
	if !is_processing_input():
		set_process_input(true)

	CurrentSpeaker.count -= 1
	Bubble.text.scroll(_translate())

func _next_line():
	# Play SE
	if ConfirmKey.SE.node != null:
		ConfirmKey.SE.node.play(ConfirmKey.SE.name)

	if is_loaded():
		# Scroll next line
		_get_line()
	else:
		# No more lines, close everything
		_close_dialogue()

########################
### Helper functions ###
########################
static func _get_slide_name(side):
	#side = bool(side)
	if !side:
		return "Left"
	else:
		return "Right"

###############
### Methods ###
###############
# Sets up a character to speak for X lines
func speak(characterID, count):
	# Safety assertions
	assert(characterID != null)
	assert(typeof(count) == TYPE_INT && count > 0)
	assert(dialogue_context != null && !dialogue_context.empty())

	# Fetching our character information
	characterID = characterID.to_upper()
	# If this character doesn't exist, avoid speaking
	if !text_collection.has(characterID):
		return
	var character = text_collection[characterID]

	# Count must not go overboard; if it does, decrease it to a minimum
	var is_overboard = (character.index + count) > character.count
	if is_overboard:
		count = character.count - character.index

	# If a side has been specified, do not switch here
	if Mugshot.specify:
		Mugshot.specify = false
	# If it has no current speaker, do not switch
	elif _has_speaker():
		if !CurrentSpeaker.name.matchn(characterID):
			_switch_side()

	# Setting up our current speaker
	CurrentSpeaker.name = characterID
	CurrentSpeaker.count = count
	_switch_mugshot(character.mugshot, character.pos)

	_open_dialogue()

# Collects information that will permit translation afterwards
func collect_lines(characterID, count):
	# Safety assertions
	assert(characterID != null && typeof(characterID) == TYPE_STRING)
	assert(typeof(count) == TYPE_INT && count > 0)

	# Preparing mugshot (if available)
	var mugshot = null
	var pos = Vector2()
	if !characterID.empty():
		var path = PATH_MUGSHOTS + characterID.capitalize() + ".tscn"
		# If the path leads to a file (why isn't there an exists() function?)
		if !path.get_file().empty():
			mugshot = load(path)
			mugshot = mugshot.instance()
			mugshot.hide()
			get_node("Mugshots").add_child(mugshot)
			pos.x = OS.get_window_size().width - (mugshot.get_texture().get_width() / mugshot.get_hframes())
	# Preparing character index
	characterID = characterID.to_upper()

	# Assigning input values to this character
	text_collection[characterID] = {
		"index"   : 0,
		"count"   : count,
		"mugshot" : mugshot,
		"pos"     : [Vector2(), pos]
	}

# Checks if there are lines left
func is_loaded():
	return CurrentSpeaker.count > 0

# Sets the game context to load in real time when speaking
func set_context(context):
	assert(typeof(context) == TYPE_STRING && !context.empty())
	dialogue_context = context

# Sets bubble type
func set_bubble_type(type):
	if typeof(type) == TYPE_STRING:
		type = ["Narrator", "Speech"].find(type)

	# Safety measure
	assert(0 <= type && type < ALL_BUBBLES.size())
	Bubble.node = _get_bubble(type)

# Sets the side to position the anchor
func set_side(side):
	assert(typeof(side) == TYPE_STRING)

	# Sets to true if side is "right"; false otherwise as a failsafe
	if Mugshot.side != side.matchn("right"):
		Mugshot.specify = true
		_switch_side()

# Adds a new sound effect to use when confirming
func set_SE(SENode = null, SEName = null):
	# If ANY of them are null, use the default SE
	if SENode == null || SEName == null:
		SENode = get_node("Confirm")
		SEName = "MSG_SOUND"
	ConfirmKey.SE.node = SENode
	ConfirmKey.SE.name = SEName
