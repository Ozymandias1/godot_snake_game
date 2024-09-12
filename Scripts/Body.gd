# Body.gd
extends Node2D
class_name Body

var peer_id: int = -1
var scale_tween: Tween = null

# 씬 트리 진입
func _enter_tree() -> void:
	self.set_multiplayer_authority(peer_id)

## 시작
#func _ready() -> void:
	## 시작시 스케일 애니메이션 처리
	#self.scale = Vector2.ZERO
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	
# 몸체 초기화
func initialize(player_peer_id: int, fill_color: Color, outline_color: Color, location: Vector2) -> void:
	self.peer_id = player_peer_id
	$Fill.modulate = fill_color
	$Outline.modulate = outline_color
	self.global_position = location

# 몸체 크기 조정 애니메이션 처리
func change_body_scale(target_scale: Vector2) -> void:
	if scale_tween:
		scale_tween.stop()
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(self, "scale", target_scale, 0.1)
