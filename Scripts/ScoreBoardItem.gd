# ScoreBoardItem.gd
extends HBoxContainer
class_name ScoreBoardItem

var score: int = 0

# 플레이어 이름 설정
func set_player_name(player_name: String) -> void:
	$PlayerName.text = player_name

# 점수 텍스트 설정
@rpc("any_peer", "call_local")
func set_score(_score: int) -> void:
	self.score = _score
	$Score.text = str(self.score)

# 점수, 플레이어 텍스트 얻기
func get_score_text() -> String:
	return $Score.text + ", " + $PlayerName.text
