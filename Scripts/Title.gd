# Title.gd
extends Control

signal on_start_game_btn_pressed
signal on_exit_btn_pressed

# Start Game 버튼 클릭 시그널
func _on_btn_start_game_pressed():
	SfxManager.play("Click")
	self.on_start_game_btn_pressed.emit()

# Exit 버튼 클릭 시그널
func _on_btn_exit_pressed():
	self.on_exit_btn_pressed.emit()
