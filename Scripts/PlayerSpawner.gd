# PlayerSpawner.gd
extends MultiplayerSpawner

const PLAYER_TEMPLATE = preload("res://Scenes/Templates/player.tscn")
@onready var players: Node = $"../Players"

# 초기 플레이어 위치들
const initial_positions: Array[Vector2] = [
	Vector2(300, 200),
	Vector2(1300, 700),
	Vector2(300, 700),
	Vector2(1300, 200),
]

# 시작
func _ready() -> void:
	self.spawn_function = self._spawn_player

# 플레이어 스폰 함수
func _spawn_player(spawn_data: Dictionary) -> Node:
	var peer_id: int = spawn_data["peer_id"]
	var player_data: Dictionary = spawn_data["player_data"]

	var player = PLAYER_TEMPLATE.instantiate()
	player.name = str(peer_id)
	player.initialize(player_data, initial_positions[players.get_child_count()])

	return player
