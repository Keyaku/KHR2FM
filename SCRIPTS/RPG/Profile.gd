extends Object

# RPG Classes
const Level       = preload("res://SCRIPTS/RPG/Level.gd")
const PlayerStats = preload("res://SCRIPTS/RPG/Stats/PlayerStats.gd")


# "Private" members
var level = Level.new()
var stats = PlayerStats.new()

func has(key):
	return key in ["level", "stats"]
