# JoinServer.gd
extends Control

# 시그널
signal on_btn_back_pressed

# Back 버튼 클릭
func _on_btn_back_pressed() -> void:
	on_btn_back_pressed.emit()
