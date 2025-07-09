class_name Game
extends Node

@onready var multiplayer_ui = $UI/Multiplayer
@onready var ip_label: Label = $UI/Ingame/VBoxContainer/Label
@onready var join_ip_lineedit: LineEdit = $UI/Multiplayer/VBoxContainer/LineEdit

const PLAYER = preload("res://player/player.tscn")

var peer = ENetMultiplayerPeer.new()
var players: Array[Player] = []

func _ready():
	$MultiplayerSpawner.spawn_function = add_player

func _on_host_pressed():
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game! (IP: " + get_local_ip() + ")")
			$MultiplayerSpawner.spawn(pid)
	)
	
	$MultiplayerSpawner.spawn(multiplayer.get_unique_id())
	multiplayer_ui.hide()


func _on_join_pressed():
	var join_ip: String = join_ip_lineedit.text
	if join_ip.is_empty():
		join_ip_lineedit.placeholder_text = "Please enter IP"
		return
	peer.create_client(join_ip, 25565)
	multiplayer.multiplayer_peer = peer
	multiplayer_ui.hide()

func add_player(pid):
	var player = PLAYER.instantiate()
	player.name = str(pid)
	player.global_position = $Level.get_child(players.size()).global_position
	players.append(player)
	
	return player

func get_random_spawnpoint():
	return $Level.get_children().pick_random().global_position

func get_local_ip() -> String:
	for addr in IP.get_local_addresses():
		if addr.begins_with("192.") or addr.begins_with("10.") or addr.begins_with("172."):
			return addr
	return str()
