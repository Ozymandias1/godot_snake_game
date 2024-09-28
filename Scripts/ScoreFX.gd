# ScoreFX.gd
extends Node2D
class_name ScoreFX

var pos_tween: Tween = null

# 시작
func _ready() -> void:
	pos_tween = get_tree().create_tween()
	pos_tween.tween_property(self, "position", self.global_position + (Vector2.UP * 100), 0.1)
	pos_tween.set_ease(Tween.EASE_OUT)
	pos_tween.set_trans(Tween.TRANS_EXPO)
	pos_tween.tween_callback(self.queue_free).set_delay(0.25)

# 점수 텍스트 설정
func set_score_text(score: int) -> void:
	$Label.text = "+%s" % score
