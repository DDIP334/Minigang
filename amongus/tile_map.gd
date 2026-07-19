extends Node2D

@onready var spawner = $MultiplayerSpawner

func _ready():
	NetworkManager.start_network()

	multiplayer.peer_connected.connect(_peer_connected)

func _peer_connected(id):
	print("Peer connected:", id)
