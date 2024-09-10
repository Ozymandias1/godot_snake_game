# Player.gd
extends Node
class_name Player

@onready var head: Node2D = $Head
@onready var name_tag_root: Node2D = $NameTagRoot

# 씬 트리구조 진입
func _enter_tree() -> void:
	self.set_multiplayer_authority(self.name.to_int())

# 업데이트
func _process(_delta: float) -> void:
	name_tag_root.global_position = head.global_position + (Vector2.UP * 16)

# 플레이어 이름표 텍스트 설정
func set_player_nametag_text(name_text: String) -> void:
	$NameTagRoot/NameTag.text = name_text

# 머리 색상 설정
func set_head_color(face_color: Color, outline_color: Color, eye_color: Color) -> void:
	$Head/Face.modulate = face_color
	$Head/FaceOutline.modulate = outline_color
	$Head/FaceEye.modulate = eye_color

# 초기 위치 설정
func set_initial_position(pos: Vector2) -> void:
	$Head.global_position = pos
