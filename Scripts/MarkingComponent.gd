# MarkingComponent.gd
# 플레이어 이동시 몸체 이동 처리를 위한 마킹 스크립트
extends Node
class_name MarkingComponent

@export var target: Node2D # 위치마킹 검사 대상

signal on_marking # 위치변화가 일어날경우 처리를 위한 시그널

var last_position: Vector2

# 시작
func _ready() -> void:
	# 시작시 검사대상의 위치를 마지막 위치로 설정
	self.last_position = target.global_position

# 업데이트
func _process(_delta: float) -> void:
	# 마지막 위치점과 검사대상의 현재 위치점간 거리값이 체크할 길이(몸체길이)를 넘어서면
	# 새로운 목표지점을 설정하기 위하여 마킹 이벤트를 발동한다.
	var distance = self.last_position.distance_to(target.global_position)
	if distance >= 32:
		self.last_position = target.global_position
		self.on_marking.emit()
