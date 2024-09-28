# BoostComponent.gd
extends Node2D
class_name BoostComponent

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var boost_not_available: Sprite2D = $TextureProgressBar/BoostNotAvailable

const BOOST_DANGER_TEXTURE = preload("res://Textures/boost_danger.png")
const BOOST_NORMAL_TEXTURE = preload("res://Textures/boost_normal.png")

var current_boost: float = 5.0
var danger_limit: float = 5.0 * 0.3
var is_exhaustion: bool = false # 탈진 여부
var is_boost_key_pressed: bool = false
var is_boost_available: float: # 부스트는 키가 눌린 상태에서 사용할 수 있는 부스트량이 남아있고 탈진상태가 아니어야함
	get:
		return (self.is_boost_key_pressed and self.current_boost > 0.0 and self.is_exhaustion == false)

# 시작
func _ready() -> void:
	self.visible = is_multiplayer_authority() # 권한이 없으면(다른 플레이어의 것이라면) 숨긴다
	self.current_boost = self.texture_progress_bar.max_value
	self.danger_limit = self.texture_progress_bar.max_value * 0.3 # 최대 부스트량의 30%를 위험상태로 설정

# 업데이트
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		self.is_boost_key_pressed = Input.is_action_pressed("Boost")
		# 부스트키 눌린상태이고 탈진상태가 아닌경우
		if self.is_boost_key_pressed and self.is_exhaustion == false:
			self.current_boost -= delta

			# 부스트를 다썼으면 탈진상태로 설정
			if self.current_boost < 0.0:
				self.is_exhaustion = true
		else:
			# 탈진상태면 키눌렸을때 원래 사용하는 양의 80% 속도로 차게 하고
			# 탈진상태가 아니라면 전체 부스트양의 50%속도로 차게한다
			if self.is_exhaustion:
				self.current_boost += delta * 0.8
			else:
				self.current_boost += delta * (self.texture_progress_bar.max_value * 0.5)
			
			# 최대 부스트량을 넘어가면 탈진상태 해제
			if self.current_boost > self.texture_progress_bar.max_value:
				self.is_exhaustion = false

		# 부스트 사용불가 텍스쳐 가시화 설정
		self.boost_not_available.visible = self.is_exhaustion
		self._set_progress_value()
		self._set_progress_texture()

# 프로그레스바 값 설정
func _set_progress_value() -> void:
	self.current_boost = clampf(self.current_boost, 0.0, self.texture_progress_bar.max_value)
	self.texture_progress_bar.value = self.current_boost

# 프로그레스바 텍스쳐 설정
func _set_progress_texture() -> void:
	# 현재 부스트량이 위험제한값 이하로 떨어지는 것을 고려하여 텍스쳐 설정
	var value_texture = BOOST_NORMAL_TEXTURE if self.current_boost > self.danger_limit else BOOST_DANGER_TEXTURE
	self.texture_progress_bar.texture_progress = value_texture
