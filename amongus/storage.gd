extends Area2D

@onready var ui = $"../../HUD/UI"
@onready var game_manager = $"../../GameManager"

func _on_body_entered(body):
	if !body.is_in_group("Player"):
		return

	print("Player entered Storage")

	var task = game_manager.get_current_task()

	if task != null and task["room"] == "Storage":
		print("Showing task panel")
		ui.show_task(task["name"])
