# Body.gd
extends Node2D
class_name Body

const BODY_COLLISION_TEMPLATE = preload("res://Scenes/Templates/body_collision.tscn")

var peer_id: int = -1
var scale_tween: Tween = null

# 씬 트리 진입
func _enter_tree() -> void:
	self.set_multiplayer_authority(peer_id)

# 몸체 초기화
func initialize(player_peer_id: int, fill_color: Color, outline_color: Color, location: Vector2, is_first_body: bool) -> void:
	self.peer_id = player_peer_id
	$Fill.modulate = fill_color
	$Outline.modulate = outline_color
	self.global_position = location
	
	if is_first_body == false:
		var collision = BODY_COLLISION_TEMPLATE.instantiate()
		self.add_child.call_deferred(collision, true)

# 몸체 크기 조정 애니메이션 처리
func change_body_scale(target_scale: Vector2) -> void:
	if scale_tween:
		scale_tween.kill()
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(self, "scale", target_scale, 0.1)
