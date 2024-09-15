# MoveComponent.gd
extends Node
class_name MoveComponent

@export var player: Player
@export var target: Node2D

# 업데이트
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		var front = target.global_transform.x
		target.global_position += player.move_speed * front * delta
