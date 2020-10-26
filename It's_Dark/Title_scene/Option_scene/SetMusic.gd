extends HBoxContainer


func _on_Slider_value_changed(value):
	if value < -37:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),value)

