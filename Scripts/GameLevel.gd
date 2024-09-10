# GameLevel.gd
extends Node

@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner

func _ready() -> void:
	if multiplayer.is_server():
		NetworkManager.on_player_connected.connect(self._on_player_connected)
		self._on_player_connected(1, NetworkManager.my_player_data)

func _on_player_connected(peer_id: int, player_data: Dictionary) -> void:
	player_spawner.spawn({
		"peer_id": peer_id,
		"player_data": player_data
	})
