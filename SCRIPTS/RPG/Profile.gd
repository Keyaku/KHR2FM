extends Object

# Signals
signal level_up(abilities)

# RPG Classes
const Level       = preload("res://SCRIPTS/RPG/Level.gd")
const PlayerStats = preload("res://SCRIPTS/RPG/Stats/PlayerStats.gd")


# "Private" members
# Levels
var exp_lv   = Level.new([])
var bonus_lv = Level.new({})

# Setting up minimal PlayerStats
var stats = PlayerStats.new({
	"lv" : 1, "bonus_lv" : 0,
	"max_hp" : 20, "max_mp" : 10,
	"str" : 1, "def" : 0,
})

###############
### Methods ###
###############
func has(key):
	return key in ["exp_lv", "bonus_lv", "stats"]

func level_up(stat, id=""):
	var rewards = []
	var lv = stats.get_base(stat)+1
	stats.set_base(stat, lv)

	if stat == "lv":
		rewards = exp_lv.get(lv)
		# TODO: set exp to 0, max_exp to the next value
	elif stat == "bonus_lv" && not id.empty():
		rewards = bonus_lv.get(id)

	emit_signal("level_up", rewards)

