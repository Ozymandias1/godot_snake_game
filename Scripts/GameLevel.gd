# GameLevel.gd
extends Node

@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner

# 시작
func _ready() -> void:
	if multiplayer.is_server():
		NetworkManager.on_player_connected.connect(self._on_player_connected)
		self._on_player_connected(1, NetworkManager.my_player_data)

# 플레이어 접속 처리
func _on_player_connected(peer_id: int, player_data: Dictionary) -> void:
	var player = player_spawner.spawn({
		"peer_id": peer_id,
		"player_data": player_data
	})
	
	# 플레이어 생성시 몸체 3개 생성
	await get_tree().create_timer(0.1).timeout
	player.add_body.rpc_id(peer_id)
	await get_tree().create_timer(0.1).timeout
	player.add_body.rpc_id(peer_id)
	await get_tree().create_timer(0.1).timeout
	player.add_body.rpc_id(peer_id)
