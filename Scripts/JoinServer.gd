# JoinServer.gd
extends Control

@onready var line_edit_ip: LineEdit = $"TabContainer/IP Address/Controls/IPContainer/LineEdit_IP"
@onready var line_edit_port: LineEdit = $"TabContainer/IP Address/Controls/PortContainer/LineEdit_Port"
@onready var btn_refresh: Button = $BtnRefresh
@onready var browser_item_container: VBoxContainer = $"TabContainer/Server Browser (LAN)/ScrollContainer/BrowserItemContainer"

const BROWSER_ITEM_TEMPLATE = preload("res://Scenes/Templates/browser_item.tscn")

# 시그널
signal on_btn_back_pressed
signal on_server_join_procced(ip: String, port: int)

func _ready() -> void:
	NetworkManager.on_server_detected.connect(self._on_server_detected)
	NetworkManager.on_get_server_info_finished.connect(self._on_get_server_info_finished)

# Back 버튼 클릭
func _on_btn_back_pressed() -> void:
	on_btn_back_pressed.emit()

# IP, Port 직접 입력하여 서버 조인
func _on_btn_join_ip_pressed() -> void:
	var ip: String = line_edit_ip.text
	var port: int = line_edit_port.text.to_int()
	
	if self.line_edit_ip.text.is_empty() or self.line_edit_port.text.is_empty():
		OS.alert("Invalid Server Info.")
		return
		
	on_server_join_procced.emit(ip, port)

# Refresh 버튼 클릭
func _on_btn_refresh_pressed() -> void:
	NetworkManager.start_get_server_info()
	self.btn_refresh.disabled = true

# 서버 탐색 종료
func _on_get_server_info_finished() -> void:
	self.btn_refresh.disabled = false

# 서버 탐지시
func _on_server_detected(ip: String, server_info: Dictionary) -> void:
	var server_name: String = server_info["name"]
	var gameplay_port: int = server_info["gameplay_port"]
	
	# 컨테이너에 항목 추가	
	if ip.is_empty() == false:
		var ip_name_check = ip.replace(".", "_")
		if browser_item_container.has_node(ip_name_check) == false:
			var item: BrowserItem = BROWSER_ITEM_TEMPLATE.instantiate()
			item.name = ip_name_check
			item.initialize(ip, server_name, gameplay_port)
			item.on_btn_join_pressed.connect(self._on_join_server_from_server_browser)
			browser_item_container.add_child(item)

# 서버 브라우져에서 Join 버튼 클릭 처리
func _on_join_server_from_server_browser(server_data: Dictionary) -> void:
	var ip: String = server_data["ip"]
	var port: int = server_data["gameplay_port"]
	on_server_join_procced.emit(ip, port)
