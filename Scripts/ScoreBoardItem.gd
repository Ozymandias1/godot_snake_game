# ScoreBoardItem.gd
extends HBoxContainer
class_name ScoreBoardItem

# 플레이어 이름 설정
func set_player_name(player_name: String) -> void:
	$PlayerName.text = player_name

# 점수 텍스트 설정
func set_score(score: int) -> void:
	$Score.text = str(score)
