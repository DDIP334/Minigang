extends Node2D

const PLAYER_SCENE := preload("res://Player.tscn")

@onready var players := $Players
func show_role_popup(role:String):

	var image = $CanvasLayer/TextureRect

	$CanvasLayer.visible = true

	if role == "IMPOSTOR":
		image.texture = load("res://assets/Impostor.PNG")
	else:
		image.texture = load("res://assets/Crewmates.PNG")

	image.visible = true

	await get_tree().create_timer(3.0).timeout

	$CanvasLayer.visible = false
func start_game():

	if !multiplayer.is_server():
		return

	if players.get_child_count() < 2:
		print("Need at least 2 players!")
		return

	var ids = []

	for p in players.get_children():
		ids.append(int(p.name))

	ids.shuffle()

	var impostor = ids[0]

	print("Impostor:", impostor)

	for id in ids:
		if id == impostor:
			rpc_id(id, "_set_role", "IMPOSTOR")
		else:
			rpc_id(id, "_set_role", "CREWMATE")

	rpc("_hide_start_button")
@rpc("authority", "call_local", "reliable")
func _set_role(role_name:String):

	print("My role is:", role_name)

	var player = players.get_node(str(multiplayer.get_unique_id()))

	if role_name == "IMPOSTOR":
		player.role = player.Role.IMPOSTOR
	else:
		player.role = player.Role.CREWMATE

	show_role_popup(role_name)
func _ready():
	$CanvasLayer/TextureRect.visible = false
	$CanvasLayer/TextureRect2.visible = false
	# Connect signals first
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# Start networking
	NetworkManager.start_network()

	# Spawn host
	if multiplayer.is_server():
		_spawn_player(multiplayer.get_unique_id())


func _on_peer_connected(id):
	print("Peer connected:", id)

	if !multiplayer.is_server():
		return

	# Send existing players
	for p in players.get_children():
		rpc_id(id, "_spawn_remote_player", int(p.name), p.position)

	# Spawn new player
	var pos := _spawn_player(id)

	# Tell everyone about the new player
	rpc("_spawn_remote_player", id, pos)

	# Wait a moment, then assign roles
	


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
	print("START BUTTON PRESSED")

	if multiplayer.is_server():
		print("HOST STARTED THE GAME")
	else:
		print("CLIENT CANNOT START")
@rpc("authority", "call_local", "reliable")
func _hide_start_button():
	$CanvasLayer/StartButton.visible = false
