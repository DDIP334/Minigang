extends CanvasLayer

@onready var task_list = $UI/Panel/MarginContainer/VBoxContainer/TaskListLabel
@onready var progress_bar = $UI/Panel/MarginContainer/VBoxContainer/ProgressBar
@onready var progress_text = $UI/Panel/MarginContainer/VBoxContainer/ProgressText

func update_ui(queue, completed, total):

	# Update Progress Bar
	progress_bar.max_value = total
	progress_bar.value = completed
	progress_text.text = str(completed) + " / " + str(total)

	# Update Task List
	task_list.clear()

	if queue.is_empty():
		task_list.append_text("[center][color=green]ALL TASKS COMPLETED![/color][/center]")
		return

	task_list.append_text("[b]Tasks[/b]\n\n")

	for i in range(queue.size()):
		if i == 0:
			task_list.append_text("[color=yellow]► " + queue[i]["name"] + " (" + queue[i]["room"] + ")[/color]\n")
		else:
			task_list.append_text("□ " + queue[i]["name"] + " (" + queue[i]["room"] + ")\n")
