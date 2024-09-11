# MoveComponent.gd
extends Node
class_name MoveComponent

@export var player: Player
@export var target: Node2D

# 업데이트
func _process(delta: float) -> void:
	if is_multiplayer_authority() and Input.is_action_pressed("Boost"): # TODO: 추후 자동이동으로 변경할것
		var front = target.global_transform.x
		target.global_position += player.move_speed * front * delta
