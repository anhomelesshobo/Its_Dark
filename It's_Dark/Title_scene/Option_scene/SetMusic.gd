extends HBoxContainer


func _on_Slider_value_changed(value):
	#Ici, on set le volume avec la value que nous recevons, si elle est plus petite que -37 alors mute la musique
	#Ne pas oublier d'utiliser le bon Bus.Dans le script j'utilise le Bus "Music" pour gérer le volume
	if value < -37:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),value)

