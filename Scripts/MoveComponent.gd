# MoveComponent.gd
extends Node
class_name MoveComponent

@export var player: Player
@export var target: Node2D

var initial_move_speed: float = 0.0
var boost_move_speed: float = 0.0

# 시작
func _ready() -> void:
	self.initial_move_speed = player.move_speed
	self.boost_move_speed = self.initial_move_speed * 1.5
	
# 업데이트
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		player.move_speed = self.boost_move_speed if Input.is_action_pressed("Boost") else self.initial_move_speed
		var front = target.global_transform.x
		target.global_position += player.move_speed * front * delta
