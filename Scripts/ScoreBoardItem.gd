# ScoreBoardItem.gd
extends HBoxContainer
class_name ScoreBoardItem

# 플레이어 이름 설정
func set_player_name(player_name: String) -> void:
	$PlayerName.text = player_name
