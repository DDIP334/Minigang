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
var current_room = "Storage"
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


func update_hud():

	hud.update_ui(task_queue, completed_tasks, tasks_per_game)
