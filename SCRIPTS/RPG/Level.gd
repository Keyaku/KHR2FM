extends Object

# Classes
const Ability = preload("Ability.gd")


# List of all abilities learned by idx = level.
# e.g. Abilities obtained at level 15 are stored in abilities[14] as an Array,
# accessible via Level.get(15)
var abilities

######################
### Core functions ###
######################
func _init(new_abilities=[]):
	if not (is_array(new_abilities) || is_dictionary(new_abilities)):
		print("Level: Given data structure is not compatible.")
		free()

	abilities = new_abilities

func _get(idx):
	if is_array(abilities):
		return abilities[idx-1] if is_valid_idx(idx) else []
	else: # it's a Dictionary
		return abilities[idx] if abilities.has(idx) else []

# Sets abilities at a given level.
func _set(idx, value):
	# Checks if it's within the boundaries of the Array in case of an Array;
	# If it's not within the bounds, it fails.
	# In any other case, it continues.
	if is_valid_idx(idx) if is_array(value) else true:
		if is_array(abilities):
			idx -= 1 # Correcting index

		# If argument is an Array of Abilities, filter it
		if is_array(value):
			# Only add valid abilities
			for ability in value:
				_add_ability(idx, ability)
		# If it's just an ability, just add it
		else:
			_add_ability(idx, value)
	else:
		print(str(value.name), " was not set: invalid index")

func _add_ability(idx, ability):
	if not (ability is Ability):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		return

	# Make room before we add it to our database
	if (is_dictionary(abilities) && not abilities.has(idx)
		|| is_array(abilities) && not is_array(abilities[idx])
	):
		abilities[idx] = []

	abilities[idx].push_back(ability)

########################
### Helper functions ###
########################
static func is_array(value):
	return typeof(value) == TYPE_ARRAY

static func is_dictionary(value):
	return typeof(value) == TYPE_DICTIONARY

func is_valid_idx(idx):
	return 0 < idx && idx < abilities.size()

###############
### Methods ###
###############
# Level value manipulation
func set_maximum_level(value):
	if is_array(abilities):
		abilities.resize(max(1, value))

