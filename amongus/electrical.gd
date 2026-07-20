extends Area2D

@onready var ui = $"../../HUD/UI"
@onready var game_manager = $"../../GameManager"
@onready var players = $"../../Players"

func _on_body_entered(body):

	print("Something entered Electrical")

	if !body.is_in_group("Player"):
		print("Not Player")
		return

	# Only the local player should open tasks
	if !body.is_multiplayer_authority():
		return
	game_manager.set_current_room("Electrical")
	# Prevent impostors from doing tasks
	if body.role == body.Role.IMPOSTOR:
		print("Impostor cannot do tasks!")
		return

	print("Player entered")

	var task = game_manager.get_current_task()

	if task != null and task["room"] == "Electrical":
		print("SHOW PANEL")
		ui.show_task(task["name"])
