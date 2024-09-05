# PlayerSetup.gd
extends Control

# 파트별 ColorRect 컨트롤
@onready var face_color_rect: ColorRect = $Container/SelectPartContainer/FaceContainer/FaceColorRect
@onready var outline_color_rect: ColorRect = $Container/SelectPartContainer/OutlineContainer/OutlineColorRect
@onready var eye_color_rect: ColorRect = $Container/SelectPartContainer/EyeContainer/EyeColorRect
# 파트별 TextureRect 컨트롤
@onready var face: TextureRect = $Container/HeadColorDisplayContainer/Face
@onready var outline: TextureRect = $Container/HeadColorDisplayContainer/Outline
@onready var eye: TextureRect = $Container/HeadColorDisplayContainer/Eye
# 색상관련 컨트롤
@onready var color_picker_title: Label = $Container/HeadColorDisplayContainer/ColorPickerContainer/ColorPickerTitle
@onready var color_picker: ColorPicker = $Container/HeadColorDisplayContainer/ColorPickerContainer/ColorPicker
# 플레이어 이름
@onready var player_name: LineEdit = $Container/PlayerNameContainer/PlayerName

# 버튼 시그널
signal on_btn_create_pressed(player_name: String, face_color: Color, outline_color: Color, eye_color: Color)
signal on_btn_join_pressed(player_name: String, face_color: Color, outline_color: Color, eye_color: Color)
signal on_btn_back_pressed

# ColorPicker 값 변경시 처리를 위한 변수
var selected_color_rect: ColorRect = null
var selected_Texture: TextureRect = null

# 시작
func _ready() -> void:
	# ColorRect 시그널 연결
	self.face_color_rect.gui_input.connect(_on_color_rect_gui_input.bind(self.face_color_rect, self.face))
	self.outline_color_rect.gui_input.connect(_on_color_rect_gui_input.bind(self.outline_color_rect, self.outline))
	self.eye_color_rect.gui_input.connect(_on_color_rect_gui_input.bind(self.eye_color_rect, self.eye))

	# ColorRect 초기 색상 설정
	self.face_color_rect.modulate = self.face.modulate
	self.outline_color_rect.modulate = self.outline.modulate
	self.eye_color_rect.modulate = self.eye.modulate
	
	# 시작시 face를 기본 선택 상태로 처리
	self._select_color_target(face_color_rect, face)

# ColorRect gui 입력 시그널
func _on_color_rect_gui_input(event: InputEvent, color_rect: ColorRect, target_texture: TextureRect) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		self._select_color_target(color_rect, target_texture)

# 색상변경할 대상 선택 처리 함수
func _select_color_target(color_rect: ColorRect, target_texture: TextureRect) -> void:
	self.selected_color_rect = color_rect
	self.selected_Texture = target_texture

	self.color_picker_title.text = selected_Texture.name
	self.color_picker.color = selected_color_rect.modulate

# ColorPicker 컨트롤 색상변경 이벤트
func _on_color_picker_color_changed(color: Color) -> void:
	self.selected_color_rect.modulate = color
	self.selected_Texture.modulate = color

# Random Color 버튼 클릭 시그널
func _on_btn_random_color_pressed() -> void:
	# 각 파트별 랜덤 색상 처리
	var color = Color(randf(), randf(), randf())
	self.face_color_rect.modulate = color
	self.face.modulate = color
	
	color = Color(randf(), randf(), randf())
	self.outline_color_rect.modulate = color
	self.outline.modulate = color
	
	color = Color(randf(), randf(), randf())
	self.eye_color_rect.modulate = color
	self.eye.modulate = color
	
	# ColorPicker 색상 설정
	self.color_picker.color = self.selected_color_rect.modulate

# Back 버튼 클릭 시그널
func _on_btn_back_pressed() -> void:
	self.on_btn_back_pressed.emit()

# Create 버튼 클릭 시그널
func _on_btn_create_pressed() -> void:
	if self.player_name.text.is_empty():
		OS.alert("Invalid Player Name.")
		return
		
	self.on_btn_create_pressed.emit(self.player_name.text, self.face.modulate, self.outline.modulate, self.eye.modulate)

# Join 버튼 클릭 시그널
func _on_btn_join_pressed() -> void:
	if self.player_name.text.is_empty():
		OS.alert("Invalid Player Name.")
		return
		
	self.on_btn_join_pressed.emit(self.player_name.text, self.face.modulate, self.outline.modulate, self.eye.modulate)
