# SteeringComponent.gd
extends Node
class_name SteeringComponent

@export var player: Player
@export var target: Node2D

# 업데이트
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		var steer_input = Input.get_axis("Steer Left", "Steer Right")
		target.rotate(player.steer_speed * steer_input * delta)
