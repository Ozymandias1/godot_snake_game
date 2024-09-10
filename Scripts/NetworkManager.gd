# NetworkManager.gd
extends Node

signal on_player_connected(peer_id: int, player_data: Dictionary)

var my_player_data: Dictionary = {}

func _ready() -> void:
	multiplayer.connected_to_server.connect(self._on_connected_to_server)

# 서버 접속 성공
func _on_connected_to_server() -> void:
	# 서버 접속 성공시 서버로 내 플레이어 정보를 전송한다
	self.receive_player_data.rpc_id(1, self.my_player_data)

# 접속한 피어로부터 플레이어 정보 수신
@rpc("any_peer", "call_local")
func receive_player_data(player_data: Dictionary) -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	self.on_player_connected.emit(peer_id, player_data)

# 서버 생성
func create_server(_server_name: String, port: int) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error:
		printerr("NetworkManager.gd create_server() -> ", error)
		
	multiplayer.multiplayer_peer = peer
	self.on_player_connected.emit(1, self.my_player_data)

# 서버조인
func join_server(ip: String, port: int) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error:
		printerr("NetworkManager.gd join_server() -> ", error)
		
	multiplayer.multiplayer_peer = peer
	
