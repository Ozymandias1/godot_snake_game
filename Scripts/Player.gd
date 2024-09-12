# Player.gd
extends Node
class_name Player

@onready var head: Node2D = $Head
@onready var name_tag_root: Node2D = $NameTagRoot
@onready var marking_component: MarkingComponent = $MarkingComponent

@export var steer_speed: float = 3.0
@export var move_speed: float = 100.0

var body_list: Array[Node2D] = []

# 씬 트리구조 진입
func _enter_tree() -> void:
	self.set_multiplayer_authority(self.name.to_int())

# 업데이트
func _process(_delta: float) -> void:
	name_tag_root.global_position = head.global_position + (Vector2.UP * 16)

	# 테스트
	if is_multiplayer_authority() and Input.is_action_just_released("TestKey"):
		$BodySpawner.spawn({"peer_id": self.name.to_int()})
		_adjust_body_scale()

# 플레이어 초기화
func initialize(player_data: Dictionary, location: Vector2) -> void:
	$NameTagRoot/NameTag.text = player_data["name"]
	$Head/Face.modulate = player_data["face"]
	$Head/FaceOutline.modulate = player_data["outline"]
	$Head/FaceEye.modulate = player_data["eye"]
	$Head.global_position = location

	$BodySpawner.player = self

	# 몸체 리스트에 머리 추가
	self.body_list.append($Head)

# 몸체 추가 함수
@rpc("call_local", "any_peer")
func add_body() -> void:
	$BodySpawner.spawn({"peer_id": self.name.to_int()})
	self._adjust_body_scale()

# 몸체 크기 조정
func _adjust_body_scale() -> void:
	print_debug("body count: ", self.body_list.size())
	var scale_array: Array[Vector2] = [
		Vector2.ONE * 0.5,
		Vector2.ONE * 0.6,
		Vector2.ONE * 0.7,
		Vector2.ONE * 0.8,
		Vector2.ONE * 0.9,
		Vector2.ONE * 1.0,
	]
	var scale_index: int = 0
	for i in range(self.body_list.size()-1, 0, -1):
		self.body_list[i].change_body_scale(scale_array[scale_index])
		scale_index += 1
		scale_index = clampi(scale_index, 0, scale_array.size()-1)
