extends Area2D

func _on_body_entered(body):
	if body is CharacterBody2D:
		body.current_room = "Storage"
		print("Entered Storage")
