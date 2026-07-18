extends CanvasLayer

@onready var game_manager = $"../GameManager"

@onready var map_sprite = $MiniMap/MapSprite
@onready var player_marker = $MiniMap/PlayerMarker
@onready var target_marker = $MiniMap/TargetMarker
@onready var line = $MiniMap/Line2D
@onready var rooms = $"../Rooms"
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

func update_map():

	var task = game_manager.get_current_task()

	if task == null:
		return

	var player_world = get_room_position(game_manager.current_room)
	var target_world = get_room_position(task["room"])

	# Convert world position to minimap position
	player_marker.position = Vector2(
		(player_world.x + 4) / 4.102 * 0.5,
		(player_world.y + 7) / 3.687 * 0.5
	)

	target_marker.position = Vector2(
		(target_world.x + 4) / 4.102 * 0.5,
		(target_world.y + 7) / 3.687 * 0.5
	)

	line.clear_points()
	line.add_point(player_marker.position)
	line.add_point(target_marker.position)
