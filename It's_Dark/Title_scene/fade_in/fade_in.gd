extends ColorRect

signal fade_finished

func fade_in():
	$AnimationPlayer.play("fade_in")
	
func fade_away():
	$AnimationPlayer.play("fade_away")


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("fade_finished")
