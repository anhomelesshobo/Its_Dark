extends KinematicBody2D

export (int) var detect_radius
export (float) var fire_rate
export (PackedScene) var Bullet
var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)

onready var ShootTimer = $ShootTimer


var hit_pos
var target
var can_shoot = true

func _ready():
	$Sprite.self_modulate = Color(0.2, 0, 0)
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	$Visibility/CollisionShape2D.shape = shape
	$ShootTimer.wait_time = fire_rate
	

func _physics_process(delta):
	update()
	if target:
		aim()
		
func aim():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, target.position, [self], collision_mask)
	if result:
		hit_pos = result.position
		if result.collider.name == "Player":
			$Sprite.self_modulate.r = 1.0
			rotation = (target.position - position).angle()
			if can_shoot:
				shoot(target.position)
			
func shoot(pos):
	print("Shoot")
	var b = Bullet.instance()
	var a = (pos - global_position).angle()
	b.start(global_position, a + rand_range(-0.05, 0.05))
	get_parent().add_child(b)
	can_shoot = false
	$ShootTimer.start()

func _draw():
	draw_circle(Vector2(), detect_radius, vis_color)
	if target:
		draw_circle((hit_pos - position).rotated(-rotation), 2, laser_color)
		draw_line(Vector2(), (hit_pos - position).rotated(-rotation), laser_color)


func _on_Visibility_body_entered(body):
	if target:
		return
	target = body
	

func _on_Visibility_body_exited(body):
	if body == target:
		target = null
		$Sprite.self_modulate.r = 0.2

func _on_ShootTimer_timeout():
	can_shoot = true
