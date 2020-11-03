extends Node2D

var Room = preload("res://Level/Room.tscn")
onready var Map = $Dungeon

var tile_size = 10
var num_rooms = 50
var min_size = 4
var max_size = 10
var hspread = 400
var vspread = 300
var cull = 0.4


var path #AStar pathfinding object
#prim's algorithm
func _ready():
	randomize()
	make_rooms()

# generateur procedural pour les rooms
func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(rand_range(vspread, hspread), 0)
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
			room.mode = RigidBody2D.MODE_STATIC
			room_positions.append(Vector3(room.position.x, room.position.y, 0))
			
	yield(get_tree(), 'idle_frame')
	# generate a minimum spanning tree connecting the rooms
	path = find_mst(room_positions)
	
func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2),Color(32,228,0),false)
	if path:
		for p in path.get_points():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y), Color(1,1,0), 15, true)
		
func _process(delta):
	update()


func _input(event):
	if event.is_action_pressed('ui_select'):
		for n in $Rooms.get_children():
			n.queue_free()
		path = null
		make_rooms()
	if event.is_action_pressed('ui_focus_next'):
		make_map()

func find_mst(nodes):
	# Prim's algorithm
	var path = AStar.new()
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
	
	#Fill TileMap with walls, then carve empty rooms
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents*2)
		full_rect = full_rect.merge(r)
	var topleft = Map.world_to_map(full_rect.position)
	var bottomright = Map.world_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(x,y,1)
		
