extends Node2D
const REQUIRED_PLAYERS := 2

var game_started := false
const PLAYER_SCENE := preload("res://Player.tscn")
@onready var role_sound = $RoleSound
@onready var kill_sound = $KillSound
@onready var victory_sound = $VictorySound
@onready var defeat_sound = $DefeatSound
const ROLE = preload("res://assets/Role.mp3")
const KILL_SOUND = preload("res://assets/Kill.mp3")
const VICTORY_SOUND = preload("res://assets/Victory.mp3")
const DEFEAT_SOUND = preload("res://assets/Defeat.mp3")
@onready var players := $Players
func show_role_popup(role:String):

	var popup = $CanvasLayer/UI/RolePopup
	var crew = popup.get_node("TextureRect")
	var imp = popup.get_node("TextureRect2")

	print("SHOWING ROLE POPUP:", role)

	# Hide both first
	crew.hide()
	imp.hide()

	if role == "IMPOSTOR":
		imp.show()
		role_sound.stream = ROLE
	else:
		crew.show()
		role_sound.stream = ROLE
	
	popup.show()
	role_sound.play()

	await get_tree().create_timer(3.0).timeout

	popup.hide()

	# Hide both after popup disappears
	crew.hide()
	imp.hide()
func show_kill_screen():

	$CanvasLayer/UI/KillScreen.show()

	await get_tree().create_timer(6.0).timeout

	$CanvasLayer/UI/KillScreen.hide()
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
func _set_role(role_name: String):

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

	# Show the role popup
	show_role_popup(role_name)
	print(
	"My ID:", multiplayer.get_unique_id(),
	"  Received role:", role_name
)
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Mouse click detected")
func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	$CanvasLayer/UI/RolePopup.hide()
	$CanvasLayer/UI/RolePopup/TextureRect.hide()
	$CanvasLayer/UI/RolePopup/TextureRect2.hide()
	$CanvasLayer/UI/KillScreen.hide()
	$CanvasLayer/UI/VictoryScreen.hide()
	$CanvasLayer/UI/DefeatScreen.hide()
	$CanvasLayer/UI/KillButton.hide()
	$CanvasLayer/UI/KillButton.disabled = false

	# rest of your code...

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	NetworkManager.start_network()

	if multiplayer.is_server():
		_spawn_player(multiplayer.get_unique_id())
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
	await get_tree().create_timer(3.0).timeout

	print("Players Connected:", players.get_child_count(), "/", REQUIRED_PLAYERS)

	if !game_started and players.get_child_count() == REQUIRED_PLAYERS:

		game_started = true

	print("All players joined. Starting game...")

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
		check_game_over()

	print("Killed:", peer_id)

	rpc("_kill_player", peer_id)
@rpc("authority","call_local","reliable")
func _kill_player(peer_id:int):

	print("KILL PLAYER RPC RECEIVED")

	if !players.has_node(str(peer_id)):
		print("VICTIM NOT FOUND")
		return

	var victim = players.get_node(str(peer_id))

	print("KILLING:", victim.name)

	kill_sound.stream = KILL_SOUND
	kill_sound.play()

	await show_kill_screen()

	victim.is_dead = true
	victim.visible = false
	victim.set_process(false)
	victim.set_physics_process(false)

	print("DEAD STATUS:", victim.is_dead)

	if multiplayer.is_server():
		print("SERVER CALLING CHECK")
		check_game_over()

func show_victory():

	print("========== VICTORY FUNCTION ==========")

	$CanvasLayer/UI/VictoryScreen.visible = true

	print("Victory Visible:",
		$CanvasLayer/UI/VictoryScreen.visible
	)
func show_defeat():

	get_tree().paused = true

	$CanvasLayer/UI/DefeatScreen.show()

	defeat_sound.stream = DEFEAT_SOUND
	defeat_sound.play()

	await defeat_sound.finished

	$CanvasLayer/UI/DefeatScreen.hide()

	get_tree().paused = false
func check_game_over():

	print("===== CHECK GAME OVER =====")

	if !multiplayer.is_server():
		print("NOT SERVER")
		return


	var alive_crewmates = 0
	var alive_impostors = 0


	for p in players.get_children():

		print(
			"Player:",
			p.name,
			" Role:",
			p.role,
			" Dead:",
			p.is_dead
		)

		if p.is_dead:
			continue


		if p.role == p.Role.CREWMATE:
			alive_crewmates += 1
		else:
			alive_impostors += 1


	print("Crew:", alive_crewmates)
	print("Imp:", alive_impostors)


	if alive_crewmates == 0:

		print("IMPOSTOR WIN CONDITION")
		rpc("_game_over","IMPOSTOR")
@rpc("authority","call_local","reliable")
func _game_over(winner:String):

	print("===== GAME OVER RPC =====")
	print("Winner:", winner)


	var me = players.get_node_or_null(str(multiplayer.get_unique_id()))


	if me == null:
		print("PLAYER NOT FOUND")
		return


	print("My role:", me.role)


	if winner == "IMPOSTOR":

		if me.role == me.Role.IMPOSTOR:
			print("CALLING VICTORY")
			show_victory()

		else:
			print("CALLING DEFEAT")
			show_defeat()
@rpc("authority", "call_local", "reliable")
func _crewmates_win():

	var me = players.get_node(str(multiplayer.get_unique_id()))

	if me.role == me.Role.CREWMATE:
		await show_victory()
	else:
		await show_defeat()
func _on_kill_button_pressed():
	print("KILL BUTTON PRESSED")
	try_kill()
