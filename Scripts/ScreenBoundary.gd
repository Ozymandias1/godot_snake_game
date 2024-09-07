# ScreenBoundary.gd
extends Area2D
class_name ScreenBoundary

enum Direction { Horizontal, Vertical }
@export var direction: Direction

# 시작
func _ready() -> void:
	# 뷰포트 크기
	var viewport_size = get_viewport_rect().size
	var scale_ratio := Vector2(viewport_size.x / 32.0, viewport_size.y / 32.0)
	# 스케일 조정
	match(direction):
		Direction.Horizontal:
			self.scale.x = scale_ratio.x
			return
		Direction.Vertical:
			self.scale.y = scale_ratio.y
			return
