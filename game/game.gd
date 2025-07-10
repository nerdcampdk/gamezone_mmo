class_name Game
extends Node

@onready var multiplayer_ui = $UI/Multiplayer
@onready var host_addr_label: Label = $UI/Ingame/VBoxContainer/HostAddrLabel
@onready var join_ip_lineedit: LineEdit = $UI/Multiplayer/VBoxContainer/IPInput
@onready var name_input: LineEdit = $UI/Multiplayer/VBoxContainer/NameInput

const PLAYER = preload("res://player/player.tscn")

var peer = ENetMultiplayerPeer.new()
var players: Array[Player] = []
var port: int;
var max_players: int

func _ready():
	$MultiplayerSpawner.spawn_function = add_player
	
	var args = OS.get_cmdline_user_args()
	for arg in args:
		var key_value = arg.rsplit("=")
		match key_value[0]:
			"port":
				port = key_value[1].to_int()
			"max_players":
				max_players = key_value[1].to_int()
	
	if DisplayServer.get_name() == "headless":
		run_server()

func _on_host_pressed():
	max_players = 64
	port = 25565
	run_server()
	
	Shared.player_name = name_input.text
	$MultiplayerSpawner.spawn(multiplayer.get_unique_id())
	multiplayer_ui.hide()
	host_addr_label.text = get_local_ip()

func _on_join_pressed():
	Shared.player_name = name_input.text
	var join_ip: String = join_ip_lineedit.text
	if join_ip.is_empty():
		join_ip_lineedit.placeholder_text = "Please enter IP"
		return
	var error = peer.create_client(join_ip, 25565)
	if error:
		join_ip_lineedit.clear()
		join_ip_lineedit.placeholder_text = "Bad IP"
		return
	multiplayer.multiplayer_peer = peer
	multiplayer_ui.hide()
	host_addr_label.text = join_ip

func add_player(pid):
	var player = PLAYER.instantiate()
	player.name = str(pid)
	# Defer setting the position until the player is in the scene tree
	player.call_deferred("set", "global_position", get_random_spawnpoint())
	players.append(player)
	
	return player

func get_random_spawnpoint():
	return $Spawnpoints.get_children().pick_random().global_position

func get_local_ip() -> String:
	for addr in IP.get_local_addresses():
		if addr.begins_with("192.") or addr.begins_with("10.") or addr.begins_with("172."):
			return addr
	return str()

func run_server():
	peer.create_server(port, max_players)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
			$MultiplayerSpawner.spawn(pid)
	)
	
	multiplayer.peer_disconnected.connect(
		func(pid):
			print("Peer " + str(pid) + " has left the game!")
			
			var player_node = get_node_or_null(str(pid))
			if player_node:
				player_node.queue_free()
			players = players.filter(func(p): return p.name != str(pid))
	)
	
	print("Server is running on port " + str(port) + " with local ip: " + get_local_ip())
