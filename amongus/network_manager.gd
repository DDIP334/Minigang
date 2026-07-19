extends Node

const PORT := 9999

var peer := ENetMultiplayerPeer.new()

var is_host := false
var server_ip := "127.0.0.1"

func start_network():

	if is_host:

		var error = peer.create_server(PORT, 8)

		if error != OK:
			print("Server Error:", error)
			return

		print("Hosting...")
		multiplayer.multiplayer_peer = peer

	else:

		var error = peer.create_client(server_ip, PORT)

		if error != OK:
			print("Client Error:", error)
			return

		print("Joining...")
		multiplayer.multiplayer_peer = peer
