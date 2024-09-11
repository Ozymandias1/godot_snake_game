# Player.gd
extends Node
class_name Player

@onready var head: Node2D = $Head
@onready var name_tag_root: Node2D = $NameTagRoot

var body_list: Array[Node2D] = []

# 씬 트리구조 진입
func _enter_tree() -> void:
	self.set_multiplayer_authority(self.name.to_int())

# 업데이트
func _process(_delta: float) -> void:
	name_tag_root.global_position = head.global_position + (Vector2.UP * 16)

func initialize(player_data: Dictionary, location: Vector2) -> void:
	$NameTagRoot/NameTag.text = player_data["name"]
	$Head/Face.modulate = player_data["face"]
	$Head/FaceOutline.modulate = player_data["outline"]
	$Head/FaceEye.modulate = player_data["eye"]
	$Head.global_position = location
	
	# 몸체 리스트에 머리 추가
	self.body_list.append($Head)
