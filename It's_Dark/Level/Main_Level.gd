extends Node2D

var Room = preload("res://Level/Room.tscn")
var Portal = preload("res://Level/Portal.tscn")
onready var Turret = preload("res://Level/Turret.tscn")
onready var Slime = preload("res://Sprites/Enemy/Slime.tscn")
onready var player = $Player
onready var Map = $TileMap
onready var Shoottime = Timer.new()
onready var Background = $Background


var random = RandomNumberGenerator.new()
var tile_size = 16
export var num_rooms = 25
var num_turret = 10
var min_size = 7
var max_size = 10
var hspread = 100
var vspread = 1000
var cull = 0.4


var path #AStar pathfinding object
var start_room = null
var end_room = null
var play_mode = false

#prim's algorithm
func _ready():
	Background.play("Background")
	randomize()
	make_rooms()
	
func _physics_process(delta):
	update()
# generateur procedural pour les rooms
func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(rand_range(vspread, hspread),rand_range(vspread, hspread))
		var r = Room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)

	# wait for movement to stop
	yield(get_tree().create_timer(1.1), 'timeout')
	# cull rooms
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_KINEMATIC
			room_positions.append(Vector3(room.position.x, room.position.y, 0))
			
	yield(get_tree(), 'idle_frame')
	# generate a minimum spanning tree connecting the rooms
	path = find_mst(room_positions)
	make_map()
	Map.update_bitmask_region()

	player.position = start_room.position
	play_mode = true
	$Camera2D/FadeIn.fade_away()
	
	
func _draw():
	if play_mode:
		return
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2),
				 Color(0, 1, 0), false)
	if path:
		for p in path.get_points():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y),
						  Color(1, 1, 0), 15, true)			
		
func _process(delta):
	update()
	



func find_mst(nodes):
	# Prim's algorithm
	path = AStar.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	# repeat until no more nodes remain
	while nodes:
		var min_dist = INF # Minumum distance so far
		var min_p = null # Position of that node
		var p = null # Current position
		# Loop through points in path
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			#loop through the ramaining nodes
			for p2 in nodes:
				if p1.distance_to(p2) <  min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
					
					
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		
		
		nodes.erase(min_p)
	return path

func make_map():
	# Create a TileMap from the generated rooms and path
	Map.clear()
	find_start_room()
	find_end_room()
	place_turret()
	
	#carve rooms
	var corridors = [] #One corridor per connection
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()
		var pos = Map.world_to_map(room.position)
		var ul = (room.position / tile_size).floor() -s
		for x in range(2,s.x * 2 -1):
			for y in range(2,s.y * 2 -1):
				Map.set_cell(ul.x + x, ul.y + y, 3)
		# Carve connecting corridor
		var p = path.get_closest_point(Vector3(room.position.x, room.position.y, 0))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.world_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = Map.world_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				carve_path(start,end)
		corridors.append(p)
		
func carve_path(pos1, pos2):
	# Carve a path between two points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	# choose either x/y or y/x
	var x_y = pos1
	var y_x = pos2
	if(randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		Map.set_cell(x, x_y.y, 3)
		Map.set_cell(x, x_y.y + y_diff,  3) #widen the corridor
		Map.set_cell(x, x_y.y + y_diff + -1, 3) #widen the corridor
		Map.set_cell(x, x_y.y + y_diff + 1, 3) #widen the corridor
		Map.set_cell(x, x_y.y + y_diff + -2, 3) #widen the corridor
		Map.set_cell(x, x_y.y + y_diff + 2, 3) #widen the corridor
	for y in range(pos1.y, pos2.y, y_diff):
		Map.set_cell(y_x.x, y, 3)	
		Map.set_cell(y_x.x + x_diff, y, 3) #widen the corridor
		Map.set_cell(y_x.x + x_diff + -1, y, 3) #widen the corridor
		Map.set_cell(y_x.x + x_diff + 1, y, 3) #widen the corridor
		Map.set_cell(y_x.x + x_diff + -2, y, 3) #widen the corridor
		Map.set_cell(y_x.x + x_diff + 2, y, 3) #widen the corridor
		
func find_start_room():
	var min_x = INF
	for room in $Rooms.get_children():
		if room.position.x < min_x:
			start_room = room
			min_x = room.position.x

func find_end_room():
	var max_x = -INF
	for room in $Rooms.get_children():
		if room.position.x > max_x:
			end_room = room
			max_x = room.position.x

func place_turret():
	var current_num_turret = 0
	for room in $Rooms.get_children():
		if room == end_room:
			var portal = Portal.instance()
			portal.position = end_room.position
			get_parent().add_child(portal)
		if room != start_room && room != end_room:
			random.randomize()
			var n = random.randi_range(1, 2)	
			if n == 1:
				var d = Slime.instance()
				var f = Slime.instance()
				d.position = room.position - Vector2(-40,-40)
				f.position = room.position - Vector2(40,40)
				get_parent().add_child(d)
				get_parent().add_child(f)
			if n == 2:
				var t = Turret.instance()
				t.position = room.position
				get_parent().add_child(t)
				if current_num_turret != 10:
					current_num_turret += 1
		
func _on_FadeIn_fade_finished():
	$Camera2D/FadeIn.hide()
	pass # Replace with function body.
