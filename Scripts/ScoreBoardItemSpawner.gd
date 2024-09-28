# ScoreBoardItemSpawner.gd
extends MultiplayerSpawner

const SCORE_BOARD_ITEM_TEMPLATE = preload("res://Scenes/Templates/score_board_item.tscn")
const SCORE_FX_TEMPLATE = preload("res://Scenes/Templates/score_fx.tscn")
@onready var container: VBoxContainer = $"../Container"
@onready var players: Node = $"../../../Players"

# 시작
func _ready() -> void:
	self.spawn_function = self._spawn_score_board_item
	self.despawned.connect(self._on_despawn_body)

func _on_despawn_body(node: Node) -> void:
	print_debug("ScoreBoardItemSpawner.gd _on_despawn_body -> ", node.name)

# 스폰 함수
func _spawn_score_board_item(spawn_data: Dictionary) -> Node:
	var peer_id: int = spawn_data["peer_id"]
	var player_data: Dictionary = spawn_data["player_data"]

	var item: ScoreBoardItem = SCORE_BOARD_ITEM_TEMPLATE.instantiate()
	item.name = str(peer_id)
	item.set_player_name(player_data["name"])

	return item

# 점수 설정
func set_score(peer_id: int, score: int) -> void:
	var target: ScoreBoardItem = container.get_node(str(peer_id))
	target.set_score.rpc(score)

# 결과 얻기(점수 큰 순서로)
func get_results() -> Array[ScoreBoardItem]:
	var score_items: Array[ScoreBoardItem] = []
	for child in container.get_children():
		if is_instance_of(child, ScoreBoardItem):
			score_items.append(child)

	score_items.sort_custom(
		func (a: ScoreBoardItem, b: ScoreBoardItem):
			return a.score > b.score
	)

	return score_items

# 점수판 항목 제거
func delete_scoreboard_item(peer_id: int) -> void:
	var del_item: ScoreBoardItem = container.get_node(str(peer_id))
	del_item.queue_free.call_deferred()

# 점수 습득 효과
@rpc("any_peer", "call_local")
func create_score_fx(peer_id: int, score: int) -> void:
	var fx: ScoreFX = SCORE_FX_TEMPLATE.instantiate()
	fx.set_score_text(score)
	get_tree().root.add_child.call_deferred(fx)
	
	var player: Player = self.players.get_node(str(peer_id))
	fx.global_position = player.head.global_position
