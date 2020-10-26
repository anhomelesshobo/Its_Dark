extends Control


func _on_ExitButton_pressed():
	$FadeIn.show()
	$FadeIn.fade_in()
	


func _on_FadeIn_fade_finished():
	get_tree().change_scene("res://Title_scene/MainMenu.tscn")
