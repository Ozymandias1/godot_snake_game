# MoveComponent.gd
extends Node
class_name MoveComponent

@export var player: Player
@export var target: Node2D
@export var boost: BoostComponent

var initial_move_speed: float = 0.0
var boost_move_speed: float = 0.0

# 시작
func _ready() -> void:
	self.initial_move_speed = player.move_speed
	self.boost_move_speed = self.initial_move_speed * 1.5 # 부스트 사용시 원래 이동속도의 150%속도로 이동

# 업데이트
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		# 부스트 사용 여부를 고려하여 이동속도 설정
		player.move_speed = self.boost_move_speed if boost.is_boost_available else self.initial_move_speed
		var front = target.global_transform.x
		target.global_position += player.move_speed * front * delta
