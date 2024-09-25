# GameLevelSpawner.gd
extends MultiplayerSpawner

const GAME_LEVEL_TEMPLATE = preload("res://Scenes/Templates/game_level.tscn")

# 시작
func _ready() -> void:
	self.spawn_function = self._spawn_level
	self.despawned.connect(self._on_despawn_body)

func _on_despawn_body(_node: Node) -> void:
	# 서버에서 먼저 종료시 클라이언트 측에서 오류가 발생한다.
	# 일단 해결방법을 찾기전까진 서버가 먼저 종료시 오류가 발생하기 전에 클라이언트앱을 다 종료 시킴
	OS.alert("서버가 게임을 종료하였습니다.", "게임종료")
	get_tree().quit()
	
# 레벨 스폰 함수
func _spawn_level(_spawn_data: Dictionary) -> Node:
	var level: Node = GAME_LEVEL_TEMPLATE.instantiate()
	return level
