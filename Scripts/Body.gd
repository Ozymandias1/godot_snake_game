# Body.gd
extends Node2D
class_name Body

var peer_id: int = -1

# 씬 트리 진입
func _enter_tree() -> void:
	self.set_multiplayer_authority(peer_id)

# 몸체 초기화
func initialize(player_peer_id: int, fill_color: Color, outline_color: Color, location: Vector2) -> void:
	self.peer_id = player_peer_id
	$Fill.modulate = fill_color
	$Outline.modulate = outline_color
	self.global_position = location
