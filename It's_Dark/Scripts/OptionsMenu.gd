extends MarginContainer

var music = 19
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Volume_value_changed(value):
	AudioServer.set_bus_volume_db(1,value)


func _on_SFX_value_changed(value):
	AudioServer.set_bus_volume_db(2,value)
	pass # Replace with function body.
