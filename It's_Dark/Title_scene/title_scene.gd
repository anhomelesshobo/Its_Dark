extends Control

var scene_path_to_load

func _ready():
	#va aller chercher tout mes boutons dans le VBoxContainer "Buttons"
	for button in $Menu/CenterRow/Buttons.get_children(): 
		#Ensuite, lorsque lui même sera appuiyer, il va appeler la méthode "_on_Button_pressed" et passe en parametre
		#la variable intégrer dans notre scene_to_load et va appeler la scene voulu
		button.connect("pressed",self,"_on_Button_pressed", [button.scene_to_load])
		
func _on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	#ici, on demarre notre FadeIn et losque notre animation player est terminer,
	#on emet un signal à notre FadeIn qui dans notre fade_in.gd et appel la fonction _on_FadeIn_fade_finished()
	#qui va changer de scene
	$FadeIn.show()
	$FadeIn.fade_in()

func _on_FadeIn_fade_finished():
	if scene_path_to_load == "quit":
		get_tree().quit()
	else:
		get_tree().change_scene(scene_path_to_load)

