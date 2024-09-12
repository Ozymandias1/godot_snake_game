# FlipComponent.gd
extends Node
class_name FlipComponent

@export var target: Node2D
@export var target_sprites: Array[Sprite2D]

func _process(_delta: float) -> void:
	if target != null:
		var direction = target.global_transform.x
		var is_flip_v = Vector2.RIGHT.dot(direction) < 0.0
		for sprite in target_sprites:
			sprite.flip_v = is_flip_v
