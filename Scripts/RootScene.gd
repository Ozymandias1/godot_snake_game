# RootScene.gd
extends Node

@onready var title: Control = $UI/Title
@onready var player_setup: Control = $UI/PlayerSetup
@onready var server_setup: Control = $UI/ServerSetup
@onready var join_server: Control = $UI/JoinServer
@onready var game_level_spawner: MultiplayerSpawner = $GameLevelSpawner
@onready var try_connect: Control = $UI/TryConnect

# 시작
func _ready() -> void:
	NetworkManager.on_server_connection_ok.connect(self._on_connect_ok)
	NetworkManager.on_server_connection_failed.connect(self._on_connect_failed)

#region Title 화면
# StartGame 버튼 클릭
func _on_title_on_start_game_btn_pressed() -> void:
	self.title.hide()
	self.player_setup.show()

# Exit 버튼 클릭
func _on_title_on_exit_btn_pressed() -> void:
	get_tree().quit()
#endregion

#region PlayerSetup 화면
# PlayerSetup-Back 버튼 클릭
func _on_player_setup_on_btn_back_pressed() -> void:
	self.title.show()
	self.player_setup.hide()

# PlayerSetup-Create 버튼 클릭
func _on_player_setup_on_btn_create_pressed(player_name: String, face_color: Color, outline_color: Color, eye_color: Color) -> void:
	# 내 플레이어 데이터 설정
	NetworkManager.my_player_data["name"] = player_name
	NetworkManager.my_player_data["face"] = face_color
	NetworkManager.my_player_data["outline"] = outline_color
	NetworkManager.my_player_data["eye"] = eye_color
	
	# UI
	self.player_setup.hide()
	self.server_setup.show()

# PlayerSetup-Join 버튼 클릭
func _on_player_setup_on_btn_join_pressed(player_name: String, face_color: Color, outline_color: Color, eye_color: Color) -> void:
	# 내 플레이어 데이터 설정
	NetworkManager.my_player_data["name"] = player_name
	NetworkManager.my_player_data["face"] = face_color
	NetworkManager.my_player_data["outline"] = outline_color
	NetworkManager.my_player_data["eye"] = eye_color
	# UI
	self.player_setup.hide()
	self.join_server.show()
#endregion

#region ServerSetup 화면
# ServerSetup-Back 버튼 클릭
func _on_server_setup_btn_back_pressed() -> void:
	self.player_setup.show()
	self.server_setup.hide()

func _on_server_setup_btn_create_pressed(server_name: String, port: int) -> void:
	# 서버생성
	NetworkManager.create_server(server_name, port)
	# 서버설정화면 숨기고 게임레벨 스폰
	self.server_setup.hide()
	game_level_spawner.spawn({})
#endregion

#region JoinServer 화면
# JoinServer-Back 버튼 클릭
func _on_join_server_on_btn_back_pressed() -> void:
	self.player_setup.show()
	self.join_server.hide()
	
# JoinServer 화면 서버 접속 시도
func _on_join_server_procced(ip: String, port: int) -> void:
	self.join_server.hide()
	
	self.try_connect.set_notice_text("Connect to \"%s\"..." % ip)
	self.try_connect.show()
	
	NetworkManager.join_server(ip, port)
#endregion

#region TryConnect 화면
# TryConnect 화면 서버 접속 성공시
func _on_connect_ok() -> void:
	self.try_connect.hide()

# TryConnect 화면 서버 접속 실패시
func _on_connect_failed() -> void:
	self.try_connect.set_notice_text("Connection failed.")

# TryConnect-Back 버튼 클릭
func _on_try_connect_on_btn_back_pressed() -> void:
	self.try_connect.hide()
	self.join_server.show()
#endregion
