# MoveComponent.gd
extends Node
class_name MoveComponent

@export var player: Player
@export var target: Node2D

var initial_move_speed: float = 0.0

# 시작
func _ready() -> void:
	self.initial_move_speed = player.move_speed

# 업데이트
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		var front = target.global_transform.x
		target.global_position += player.move_speed * front * delta
