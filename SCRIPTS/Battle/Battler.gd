extends KinematicBody2D

# Signals
signal defeated

# Classes
const BattlerStats = preload("res://SCRIPTS/RPG/Stats/BattlerStats.gd")

# Export values
export(int, 100, 300) var battler_speed = 100 # Pixels/second
export(bool) var override_stats = false
export(int, 1, 2000) var max_health = 1
export(int, 0, 2000) var max_mana   = 0
export(int, 1, 100) var strength    = 1
export(int, 1, 100) var defense     = 1

# Instance members
onready var HUD = KHR2.get_node("HUD")
var stats

######################
### Core functions ###
######################
func _ready():
	add_to_group("Battler")
	fight()

###############
### Methods ###
###############
### Overloading functions
func get_type():
	return "Battler"

func is_type(type):
	return get_type() == type

func set_y(y):
	var x = get_position().x  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	set_position(Vector2(x, y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

### Battler control
func fight():
	set_physics_process(true)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func at_ease():
	set_physics_process(false)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

