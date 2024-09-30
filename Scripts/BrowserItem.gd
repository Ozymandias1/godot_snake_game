# BrowserItem.gd
extends HBoxContainer
class_name BrowserItem

signal on_btn_join_pressed(server_data: Dictionary)

var server_data: Dictionary = {}

# 초기화
func initialize(server_ip: String, server_name: String, gameplay_port: int) -> void:
	self.server_data["ip"] = server_ip
	self.server_data["server_name"] = server_name
	self.server_data["gameplay_port"] = gameplay_port

	$ServerName.text = server_name

# Join버튼 클릭
func _on_btn_join_pressed() -> void:
	self.on_btn_join_pressed.emit(self.server_data)
