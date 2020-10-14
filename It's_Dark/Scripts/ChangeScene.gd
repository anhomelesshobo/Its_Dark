extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Enter_pressed():
	get_tree().change_scene("res://Scenes/Level-Test.tscn")
	pass # Replace with function body.


func _on_Options_pressed():
	get_tree().change_scene("res://Scenes/OptionsMenu.tscn")
	pass # Replace with function body.


func _on_Exit_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_OptionExit_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
	pass # Replace with function body.
