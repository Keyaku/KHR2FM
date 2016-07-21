extends CanvasLayer

######################
### Core functions ###
######################

var oldHP = 100
onready var GreenBar = get_node("GreenBar")
onready var SlideHit = get_node("SlideHit")

func _set_HP(curHP):
	GreenBar.set_scale(Vector2(curHP/100,0))

func update(curHP):
	while curHP > 100:
		#TODO: Update for bubbles here
		curHP = curHP - 100
	_set_HP(curHP)
	if(curHP > oldHP):
		#Happens in debug or if heal or during one bubble shot
		#SlideHit is 2secs long so *2
		SlideHit.seek((curHP/100)*2)
	#TODO: Add Timer for life drawing anim and play SlideHit!
	oldHP = curHP
