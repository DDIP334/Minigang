extends Node

# =========================
# ALL AVAILABLE TASKS
# =========================
var all_tasks = [
	{"name":"Fix Wires","room":"Electrical"},
	{"name":"Swipe Card","room":"Admin"},
	{"name":"Fuel Engine","room":"LowerEngine"},
	{"name":"Calibrate Engine","room":"UpperEngine"},
	{"name":"Upload Data","room":"Communication"},
	{"name":"Empty Garbage","room":"Storage"},
	{"name":"Inspect Sample","room":"Observation"},
	{"name":"Start Reactor","room":"Engine"}
]

# Player's current room
var current_room : String = ""

# Queue
var task_queue = []

@export var tasks_per_game := 3

var completed_tasks := 0

@onready var hud = $"../HUD"

func _ready():
	await get_tree().process_frame
	start_new_game()

func start_new_game():

	task_queue.clear()
	completed_tasks = 0

	var temp = all_tasks.duplicate()
	temp.shuffle()

	for i in range(min(tasks_per_game, temp.size())):
		task_queue.append(temp[i])

	update_hud()


# ===================================================
# Called ONLY when player enters a room
# ===================================================
func set_current_room(room_name: String):

	if current_room == room_name:
		return

	current_room = room_name

	print("Current Room:", current_room)

	var map = get_parent().get_node_or_null("MapUI")

	if map != null and map.visible:
		map.update_map()


func get_current_task():

	if task_queue.is_empty():
		return null

	return task_queue.front()


func complete_task():

	if task_queue.is_empty():
		return

	task_queue.pop_front()

	completed_tasks += 1

	update_hud()

	check_all_tasks_completed()


func update_hud():

	hud.update_ui(task_queue, completed_tasks, tasks_per_game)


func check_all_tasks_completed():

	if completed_tasks < tasks_per_game:
		return

	print("ALL TASKS COMPLETED!")

	if multiplayer.is_server():
		get_parent().rpc("_crewmates_win")
	else:
		get_parent().rpc_id(1, "_request_crewmate_win")
