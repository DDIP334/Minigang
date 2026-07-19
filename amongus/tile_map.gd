extends Node2D

const PLAYER_SCENE := preload("res://Player.tscn")

@onready var players := $Players

func _ready():
	NetworkManager.start_network()

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	if multiplayer.is_server():
		_spawn_player(1)

func _on_peer_connected(id):
	print("Peer connected:", id)

	if multiplayer.is_server():
		_spawn_player(id)

func _on_peer_disconnected(id):
	if players.has_node(str(id)):
		players.get_node(str(id)).queue_free()

func _spawn_player(peer_id:int):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)

	# Spawn almost on top of each other
	if players.get_child_count() == 0:
		player.position = Vector2(400, 400)
	else:
		player.position = Vector2(420, 400)

	players.add_child(player)

	rpc("_spawn_remote_player",peer_id,player.position)
@rpc("authority","call_remote","reliable")
func _spawn_remote_player(peer_id:int,pos:Vector2):

	if multiplayer.is_server():
		return

	if players.has_node(str(peer_id)):
		return

	var player = PLAYER_SCENE.instantiate()

	player.name = str(peer_id)

	player.set_multiplayer_authority(peer_id)

	player.position = pos

	players.add_child(player)
