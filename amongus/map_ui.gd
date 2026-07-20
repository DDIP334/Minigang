extends CanvasLayer

@onready var game_manager = $"../GameManager"

@onready var map_sprite = $MiniMap/MapSprite
@onready var player_marker = $MiniMap/PlayerMarker
@onready var target_marker = $MiniMap/TargetMarker
@onready var line = $MiniMap/Line2D
@onready var rooms = $"../Rooms"
var graph = {
	"Cafeteria": ["Engine", "Electrical"],
	"Engine": ["Cafeteria", "Admin"],
	"Admin": ["Engine", "LowerEngine"],
	"LowerEngine": ["Admin", "Communication"],
	"Communication": ["LowerEngine", "Storage"],
	"Storage": ["Communication", "Observation", "UpperEngine"],
	"UpperEngine": ["Storage", "Security"],
	"Security": ["UpperEngine", "Electrical"],
	"Electrical": ["Security", "Cafeteria"],
	"Observation": ["Storage"]
}
var minimap_points = {
	"Cafeteria": Vector2(576.0, 99.0),
	"Engine": Vector2(268.0, 120.0),
	"Electrical": Vector2(860.0, 119.0),
	"Admin": Vector2(147.0, 285.0),
	"Security": Vector2(999.0, 289.0),
	"Communication": Vector2(405.0, 407.0),
	"LowerEngine": Vector2(264.0, 486.0),
	"Storage": Vector2(550.0, 567.0),
	"Observation": Vector2(703.0, 592.0),
	"UpperEngine": Vector2(863.0, 515.0)
}
func bfs(start_room:String, end_room:String):

	var queue = [start_room]
	var visited = {}
	var parent = {}

	visited[start_room] = true

	while queue.size() > 0:

		var current = queue.pop_front()

		if current == end_room:
			break

		for next in graph[current]:

			if !visited.has(next):

				visited[next] = true
				parent[next] = current
				queue.push_back(next)

	var path = []

	if start_room == end_room:
		path.append(start_room)
		return path

	if !parent.has(end_room):
		return []

	var node = end_room

	while node != start_room:

		path.push_front(node)
		node = parent[node]

	path.push_front(start_room)

	return path
func get_room_position(room_name):

	var room = rooms.get_node(room_name)

	if room == null:
		return Vector2.ZERO

	var point = room.get_node("MapPoint")

	return point.global_position

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("map"):
		visible = !visible

	if visible:
		update_map()
func _process(delta):
	if visible:
		update_map()

func update_map():

	var task = game_manager.get_current_task()

	if task == null:
		return

	# Get current room from GameManager
	var current_room = game_manager.current_room

	# Safety check
	if !minimap_points.has(current_room):
		print("Unknown current room:", current_room)
		return

	if !minimap_points.has(task["room"]):
		print("Unknown target room:", task["room"])
		return

	# Update markers
	player_marker.position = minimap_points[current_room]
	target_marker.position = minimap_points[task["room"]]

	# Draw BFS path
	line.clear_points()

	var path = bfs(current_room, task["room"])

	for room in path:
		line.add_point(minimap_points[room])

	print("Current Room:", current_room)
	print("Target Room:", task["room"])
	print("Path:", path)
