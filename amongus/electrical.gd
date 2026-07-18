extends Area2D

@onready var ui = $"../../HUD/UI"
@onready var game_manager = $"../../GameManager"

func _on_body_entered(body):
	print("Something entered Electrical")

	if !body.is_in_group("Player"):
		print("Not Player")
		return

	print("Player entered")

	var task = game_manager.get_current_task()

	print(task)

	if task != null:
		print("Current task room = ", task["room"])

	if task != null and task["room"] == "Electrical":
		print("SHOW PANEL")
		ui.show_task(task["name"])
