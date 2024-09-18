# FollowComponent.gd
extends Node
class_name FollowComponent

@export var follow_object: Node2D # 이동 대상
@export var follow_target: Node2D # 따라갈 대상

var player: Player # 이 몸체가 속한 플레이어
var target_position: Vector2 # 목표 위치

# 업데이트
func _process(delta: float) -> void:
	if follow_target != null:
		var direction = (target_position - follow_object.global_position).normalized()
		follow_object.global_position += direction * player.move_speed * delta
		follow_object.look_at(follow_target.global_position)

# 목표위치 업데이트
func update_target_position() -> void:
	if follow_target != null:
		target_position = follow_target.global_position
