# ScoreBoardItemSpawner.gd
extends MultiplayerSpawner

const SCORE_BOARD_ITEM_TEMPLATE = preload("res://Scenes/Templates/score_board_item.tscn")

# 시작
func _ready() -> void:
	self.spawn_function = self._spawn_score_board_item

# 스폰 함수
func _spawn_score_board_item(spawn_data: Dictionary) -> Node:
	var peer_id: int = spawn_data["peer_id"]
	var player_data: Dictionary = spawn_data["player_data"]
	
	var item: ScoreBoardItem = SCORE_BOARD_ITEM_TEMPLATE.instantiate()
	item.name = str(peer_id)
	item.set_player_name(player_data["name"])
	
	return item
