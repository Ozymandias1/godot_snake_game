# PlayerSpawner.gd
extends MultiplayerSpawner

const PLAYER_TEMPLATE = preload("res://Scenes/Templates/player.tscn")
@onready var players: Node = $"../Players"

# 초기 플레이어 상태
const initial_state: Array[Dictionary] = [
	{ "location": Vector2(300, 200), "angle": 0 },
	{ "location": Vector2(1300, 700), "angle": PI },
	{ "location": Vector2(300, 200), "angle": 0 },
	{ "location": Vector2(1300, 200), "angle": PI },
]

# 시작
func _ready() -> void:
	self.spawn_function = self._spawn_player

# 플레이어 스폰 함수
func _spawn_player(spawn_data: Dictionary) -> Node:
	var peer_id: int = spawn_data["peer_id"]
	var player_data: Dictionary = spawn_data["player_data"]

	var player: Player = PLAYER_TEMPLATE.instantiate()
	player.name = str(peer_id)
	player.initialize(player_data, initial_state[players.get_child_count()])

	return player
