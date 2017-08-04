extends Object

# RPG Classes
const Level       = preload("res://SCRIPTS/RPG/Level.gd")
const PlayerStats = preload("res://SCRIPTS/RPG/Stats/PlayerStats.gd")


# "Private" members
var level = Level.new()
var stats = PlayerStats.new({
	"lv" : 1,
	"max_hp" : 50, "hp" : 50,
})

func has(key):
	return key in ["level", "stats"]
