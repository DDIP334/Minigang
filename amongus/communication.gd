extends Area2D

@onready var ui = $"../../HUD/UI"
@onready var game_manager = $"../../GameManager"

func _on_body_entered(body):

	if !body.is_in_group("Player"):
		return

	# Only the local player can open the task
	if !body.is_multiplayer_authority():
		return
	game_manager.set_current_room("Communication")
	# Impostor cannot perform tasks
	if body.role == body.Role.IMPOSTOR:
		print("Impostor cannot do tasks!")
		return

	print("Player entered Communication")

	var task = game_manager.get_current_task()

	if task != null and task["room"] == "Communication":
		print("Showing task panel")
		ui.show_task(task["name"])
