# GameLevelSpawner.gd
extends MultiplayerSpawner

const GAME_LEVEL_TEMPLATE = preload("res://Scenes/Templates/game_level.tscn")

# 시작
func _ready() -> void:
	self.spawn_function = self._spawn_level
	
# 레벨 스폰 함수
func _spawn_level(_spawn_data: Dictionary) -> Node:
	var level: Node = GAME_LEVEL_TEMPLATE.instantiate()
	return level
