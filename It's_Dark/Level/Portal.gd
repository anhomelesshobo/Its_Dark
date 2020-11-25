extends Area2D






func _on_Portal_area_entered(area):
	get_tree().change_scene("res://Title_scene/MainMenu.tscn")
