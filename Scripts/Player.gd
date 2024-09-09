extends Node
class_name Player

func _enter_tree() -> void:
	self.set_multiplayer_authority(self.name.to_int())

func set_initial_position(pos: Vector2) -> void:
	$Head.global_position = pos
