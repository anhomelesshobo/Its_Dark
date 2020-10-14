extends KinematicBody2D

export (int) var speed = 100
export var weapon_speed = 400
export var fire_rate = 0.7


var Weapons = preload("res://Scenes/Weapon.tscn")
var can_fire = true
var directions = ["Right", "DownRight", "Down", "DownLeft", "Left", "UpLeft", "Up", "UpRight"]#To know which animation to play
var weapon_direction = [0,65,90,115,180,-125,-90,-55]
var current_weapon_direction = weapon_direction[0]
var facing = Vector2()#To know which angle im facing currently
var velocity = Vector2()


func _process(delta):
	
	
	if Input.is_action_pressed("click") and can_fire:
		var weapons_instance = Weapons.instance()
		
		if facing.angle() < 3 and facing.angle() > 0:
			weapons_instance.position = $WeaponPoint.get_global_position()			
		elif facing.angle() == 0:
			weapons_instance.position = get_global_position() + Vector2(4,0)	
		elif facing.angle() > -3 and facing.angle() < 0:
			weapons_instance.position = get_global_position() + Vector2(0,-4.2)
		else:
			weapons_instance.position = get_global_position() + Vector2(-4,0)
		
		weapons_instance.rotation_degrees = current_weapon_direction
		weapons_instance.apply_impulse(Vector2(), Vector2(weapon_speed,0).rotated(facing.angle()))
		get_tree().get_root().add_child(weapons_instance)
		can_fire = false
		yield(get_tree().create_timer(fire_rate),"timeout")
		can_fire=true

func _physics_process(delta):
	velocity = Vector2()#To be able to move in the map

	var LEFT = Input.is_action_pressed("left")#True or False
	var RIGHT = Input.is_action_pressed("right")#True or False
	var UP = Input.is_action_pressed("up")#True or False
	var DOWN = Input.is_action_pressed("down")#True or False

	if !LEFT && !RIGHT && !UP && !DOWN: # If all false be idle
		$AnimatedSprite.play("Idle")
	else:			
		velocity.x = int(RIGHT) - int(LEFT)# look if we go Left(-1) or right(1)
		velocity.y = int(DOWN) - int(UP)# look if we go Down(1) or Up(1)

		if LEFT || RIGHT || UP || DOWN: # If one of these is true ill face my velocity
			facing = velocity

		velocity = velocity.normalized() * speed # If we go diagonal we need to set the speed to 1 and the speed needed
		
		var animation = direction2str(facing)# and look for the animation needed with the position we are facing
		
		if $AnimatedSprite.animation != animation:
			$AnimatedSprite.play(animation)
			
		

		velocity = move_and_slide(velocity)

func direction2str(direction): #to find the number for the direction im facing and play the animation
	var angle = direction.angle()
	if angle < 0:
		angle += 2 * PI #add with 360 degres or 6,2832 radians
	var index = round(angle / PI * 4)#we take the angle and divide it by 720 degres or 12,566... radians
	current_weapon_direction = weapon_direction[index]
	return directions[index]#with this it will give the index from 0 to 7 so we can get the right animation 
