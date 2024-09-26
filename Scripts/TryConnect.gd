# TryConnect.gd
extends Control

signal on_btn_back_pressed

@onready var label_notice: Label = $LabelNotice

# 알림 라벨 텍스트 설정
func set_notice_text(text: String) -> void:
	self.label_notice.text = text

# Back 버튼 클릭 시그널
func _on_btn_back_pressed() -> void:
	SfxManager.play("Click")
	self.on_btn_back_pressed.emit()
