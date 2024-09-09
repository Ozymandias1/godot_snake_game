# GameLevel.gd
extends Node

@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(self._on_peer_connected)

func _on_peer_connected(peer_id: int) -> void:
	player_spawner.spawn({
		"peer_id": peer_id
	})
