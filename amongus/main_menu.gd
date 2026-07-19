extends Control

@onready var ip_input = $Menu/IPInput

func _on_host_button_pressed():
	NetworkManager.is_host = true
	get_tree().change_scene_to_file("res://tile_map.tscn")


func _on_join_button_pressed():

	NetworkManager.is_host = false

	if ip_input.text.is_empty():
		NetworkManager.server_ip = "127.0.0.1"
	else:
		NetworkManager.server_ip = ip_input.text

	get_tree().change_scene_to_file("res://tile_map.tscn")
