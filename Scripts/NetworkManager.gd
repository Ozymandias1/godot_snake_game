# NetworkManager.gd
extends Node

# 서버 생성
func create_server(server_name: String, port: int, player_data: Dictionary) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error:
		printerr("NetworkManager.gd create_server() -> ", error)
		
	multiplayer.multiplayer_peer = peer

# 서버조인
func join_server(ip: String, port: int, player_data: Dictionary) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error:
		printerr("NetworkManager.gd join_server() -> ", error)
		
	multiplayer.multiplayer_peer = peer
