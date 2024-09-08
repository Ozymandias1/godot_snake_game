# JoinServer.gd
extends Control

@onready var line_edit_ip: LineEdit = $"TabContainer/IP Address/Controls/IPContainer/LineEdit_IP"
@onready var line_edit_port: LineEdit = $"TabContainer/IP Address/Controls/PortContainer/LineEdit_Port"

# 시그널
signal on_btn_back_pressed
signal on_server_join_procced(ip: String, port: int)

# Back 버튼 클릭
func _on_btn_back_pressed() -> void:
	on_btn_back_pressed.emit()

# IP, Port 직접 입력하여 서버 조인
func _on_btn_join_ip_pressed() -> void:
	var ip: String = line_edit_ip.text
	var port: int = line_edit_port.text.to_int()
	on_server_join_procced.emit(ip, port)
