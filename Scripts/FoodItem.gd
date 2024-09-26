# FoodItem.gd
extends Area2D
class_name FoodItem

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# 시작
func _ready() -> void:
	# 무작위 스프라이트 프레임 설정
	var frame_count = self.animated_sprite_2d.sprite_frames.get_frame_count("Foods")
	var sel_index = randi_range(0, frame_count - 1)
	self.animated_sprite_2d.frame = sel_index
	
	# 무작위 회전
	self.rotate(randf_range(0, PI * 2.0))
