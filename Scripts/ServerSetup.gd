# ServerSetup.gd
extends Control

# 컨트롤 변수
@onready var server_name: LineEdit = $Container/ServerNameContainer/ServerName
@onready var port_number: LineEdit = $Container/PortContainer/PortNumber

# 버튼 시그널
signal on_btn_back_pressed
signal on_btn_create_pressed(server_name: String, port: int)

# Back 버튼 클릭
func _on_btn_back_pressed() -> void:
	self.on_btn_back_pressed.emit()

# Create 버튼 클릭
func _on_btn_create_pressed() -> void:
	self.on_btn_create_pressed.emit(self.server_name.text, self.port_number.text.to_int())
