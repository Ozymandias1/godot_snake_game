# RootScene.gd
extends Node

@onready var title: Control = $UI/Title
@onready var player_setup: Control = $UI/PlayerSetup

#region Title 화면
# StartGame 버튼 클릭
func _on_title_on_start_game_btn_pressed() -> void:
	title.hide()
	player_setup.show()

# Exit 버튼 클릭
func _on_title_on_exit_btn_pressed() -> void:
	get_tree().quit()
#endregion

#region PlayerSetup 화면
# PlayerSetup-Back 버튼 클릭
func _on_player_setup_on_btn_back_pressed() -> void:
	title.show()
	player_setup.hide()

# PlayerSetup-Create 버튼 클릭
func _on_player_setup_on_btn_create_pressed(player_name: String, face_color: Color, outline_color: Color, eye_color: Color) -> void:
	pass # Replace with function body.

# PlayerSetup-Join 버튼 클릭
func _on_player_setup_on_btn_join_pressed(player_name: String, face_color: Color, outline_color: Color, eye_color: Color) -> void:
	pass # Replace with function body.
#endregion
