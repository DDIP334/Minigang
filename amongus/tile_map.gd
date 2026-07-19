extends Node2D

const PLAYER_SCENE := preload("res://Player.tscn")

@onready var players := $Players
func show_role_popup(role:String):

	print("SHOWING ROLE POPUP:", role)

	var popup = $CanvasLayer/UI/RolePopup
	var image = popup.get_node("TextureRect")

	if role == "IMPOSTOR":
		image.texture = load("res://assets/Imposter.PNG")
	else:
		image.texture = load("res://assets/Crewmates.PNG")

	popup.show()

	await get_tree().create_timer(3.0).timeout

	popup.hide()
func start_game():

	if !multiplayer.is_server():
		return

	var ids := []

	for p in players.get_children():
		ids.append(int(p.name))

	if ids.size() < 2:
		return

	ids.shuffle()

	var impostor = ids[0]

	print("Impostor is:", impostor)

	for id in ids:
		if id == impostor:
			rpc_id(id, "_set_role", "IMPOSTOR")
		else:
			rpc_id(id, "_set_role", "CREWMATE")
@rpc("authority", "call_local", "reliable")
func _set_role(role_name:String):

	print("I am:", role_name)

	var player = players.get_node_or_null(str(multiplayer.get_unique_id()))

	if player == null:
		print("Player not found!")
		return

	if role_name == "IMPOSTOR":
		player.role = player.Role.IMPOSTOR
		$CanvasLayer/UI/KillButton.show()
	else:
		player.role = player.Role.CREWMATE
		$CanvasLayer/UI/KillButton.hide()

	print("KillButton visible:", $CanvasLayer/UI/KillButton.visible)

	# TEMPORARILY DISABLED
	# show_role_popup(role_name)
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Mouse click detected")
func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Ready")

	# Hide popup
	$CanvasLayer/UI/RolePopup.hide()

	# Force show KillButton
	$CanvasLayer/UI/KillButton.show()
	$CanvasLayer/UI/KillButton.disabled = false

	print("Button global position: ", $CanvasLayer/UI/KillButton.global_position)
	print("Button size: ", $CanvasLayer/UI/KillButton.size)
	print("Button visible: ", $CanvasLayer/UI/KillButton.visible)

	# Test mouse
	$CanvasLayer/UI/KillButton.mouse_entered.connect(func():
		print("ENTER BUTTON")
	)

	# Connect networking
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	NetworkManager.start_network()

	if multiplayer.is_server():
		_spawn_player(multiplayer.get_unique_id())
	print("RolePopup mouse filter:", $CanvasLayer/UI/RolePopup.mouse_filter)
	print("ColorRect mouse filter:", $CanvasLayer/UI/RolePopup/ColorRect.mouse_filter)
func _on_peer_connected(id):
	print("Peer connected:", id)

	if !multiplayer.is_server():
		return

	# Send existing players to the new client
	for p in players.get_children():
		rpc_id(id, "_spawn_remote_player", int(p.name), p.position)

	# Spawn new player
	var pos := _spawn_player(id)

	# Tell everyone about the new player
	rpc("_spawn_remote_player", id, pos)

	# Wait until everyone is spawned
	await get_tree().create_timer(1.0).timeout

	# Automatically assign roles when there are 2 or more players
	if players.get_child_count() >= 2:
		start_game()


func _on_peer_disconnected(id):
	if players.has_node(str(id)):
		players.get_node(str(id)).queue_free()

	rpc("_remove_remote_player", id)


func _spawn_player(peer_id:int) -> Vector2:

	# Prevent duplicate spawn
	if players.has_node(str(peer_id)):
		return players.get_node(str(peer_id)).position

	var player = PLAYER_SCENE.instantiate()

	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)

	# Simple spawn positions
	var pos := Vector2(400 + players.get_child_count() * 40, 400)

	player.position = pos

	players.add_child(player)

	return pos


@rpc("any_peer","call_remote","reliable")
func _spawn_remote_player(peer_id:int, pos:Vector2):

	# Server already has everyone
	if multiplayer.is_server():
		return

	if players.has_node(str(peer_id)):
		return

	var player = PLAYER_SCENE.instantiate()

	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	player.position = pos

	players.add_child(player)


@rpc("any_peer","call_remote","reliable")
func _remove_remote_player(peer_id:int):

	if players.has_node(str(peer_id)):
		players.get_node(str(peer_id)).queue_free()


func _on_start_button_pressed():
	if multiplayer.is_server():
		start_game()
	else:
		print("Only the host can start the game")

	
func try_kill():

	var my_player = players.get_node(str(multiplayer.get_unique_id()))

	for p in players.get_children():

		if p == my_player:
			continue

		# Only kill crewmates
		if p.role == p.Role.IMPOSTOR:
			continue

		if my_player.position.distance_to(p.position) < 60:

			rpc_id(1, "_server_kill_player", int(p.name))
			return
@rpc("any_peer","call_local","reliable")
func _server_kill_player(peer_id:int):

	if !multiplayer.is_server():
		return

	print("Killed:", peer_id)

	rpc("_kill_player", peer_id)
@rpc("authority","call_local","reliable")
func _kill_player(peer_id:int):

	if !players.has_node(str(peer_id)):
		return

	var victim = players.get_node(str(peer_id))

	victim.visible = false
	victim.set_process(false)
	victim.set_physics_process(false)

	print(peer_id, "is dead")


func _on_kill_button_pressed():
	print("KILL BUTTON PRESSED")
	try_kill()
