extends Object

# RPG Classes
const Level       = preload("res://SCRIPTS/RPG/Level.gd")
const PlayerStats = preload("res://SCRIPTS/RPG/Stats/PlayerStats.gd")


# "Private" members
# Levels
var exp_level   = Level.new([])
var bonus_level = Level.new({})

var stats = PlayerStats.new({
	"lv" : 1, "bonus_lv" : 0,
	"max_hp" : 20, "max_mp" : 10,
	"str" : 1, "def" : 0,
})

func has(key):
	return key in ["exp_level", "bonus_level", "stats"]
