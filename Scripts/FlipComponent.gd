# FlipComponent.gd
extends Node
class_name FlipComponent

@export var target: Node2D
@export var target_sprites: Array[Sprite2D]

# 업데이트
func _process(_delta: float) -> void:
	if target != null:
		# 방향에 따라 스프라이트 Flip 설정
		var direction = target.global_transform.x
		var is_flip_v = Vector2.RIGHT.dot(direction) < 0.0
		for sprite in target_sprites:
			sprite.flip_v = is_flip_v
