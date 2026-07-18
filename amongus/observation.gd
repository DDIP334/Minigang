extends Area2D

@onready var ui = $"../../HUD/UI"
@onready var game_manager = $"../../GameManager"

func _on_body_entered(body):
	if !body.is_in_group("Player"):
		return

	print("Player entered Observation")

	var task = game_manager.get_current_task()

	print("Task = ", task)

	if task != null:
		print("Task room = ", task["room"])

	# TEMPORARY TEST
	ui.show_task("TEST TASK")
