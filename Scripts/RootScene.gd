# RootScene.gd
extends Node

@onready var title: Control = $UI/Title
@onready var player_setup: Control = $UI/PlayerSetup
@onready var server_setup: Control = $UI/ServerSetup

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
	self.player_setup.hide()
	self.server_setup.show()

# PlayerSetup-Join 버튼 클릭
func _on_player_setup_on_btn_join_pressed(player_name: String, face_color: Color, outline_color: Color, eye_color: Color) -> void:
	pass # Replace with function body.
#endregion

#region ServerSetup 화면
# ServerSetup-Back 버튼 클릭
func _on_server_setup_btn_back_pressed() -> void:
	self.player_setup.show()
	self.server_setup.hide()

func _on_server_setup_btn_create_pressed(server_name: String, port: int) -> void:
	print_debug("server_name, port -> [%s, %s]" % [server_name, port])
#endregion
