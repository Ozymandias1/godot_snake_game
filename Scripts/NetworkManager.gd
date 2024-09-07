# NetworkManager.gd
extends Node

# 서버 생성
func create_server(server_name: String, port: int, player_data: Dictionary) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error:
		printerr(error)
		
	multiplayer.multiplayer_peer = peer
