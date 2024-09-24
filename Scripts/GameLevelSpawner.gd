# GameLevelSpawner.gd
extends MultiplayerSpawner

const GAME_LEVEL_TEMPLATE = preload("res://Scenes/Templates/game_level.tscn")

# 시작
func _ready() -> void:
	self.spawn_function = self._spawn_level
	self.despawned.connect(self._on_despawn_body)

func _on_despawn_body(node: Node) -> void:
	# multiplayer.server_disconnected에서 종료시키면 오류가 발생하므로 여기서 종료 시킴
	#OS.alert("서버가 게임을 종료하였습니다.", "게임종료")
	#get_tree().quit()
	pass
	
# 레벨 스폰 함수
func _spawn_level(_spawn_data: Dictionary) -> Node:
	var level: Node = GAME_LEVEL_TEMPLATE.instantiate()
	return level
