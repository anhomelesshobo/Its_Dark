extends Control

var life = 10 setget set_life
var max_life = 10 setget set_max_life

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty


func set_life(value):
	life = clamp(value, 0 , max_life)
	if heartUIFull != null:
		heartUIFull.rect_size.x = life * 15
	
	
func set_max_life(value):
	max_life = max(value,1)
	self.life = min(life, max_life)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_life * 15
	
func _ready():
	self.max_life = PlayerStats.max_health
	self.life = PlayerStats.health
	PlayerStats.connect("life_changed", self , "set_life")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	


