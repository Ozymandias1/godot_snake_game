# Player.gd
extends Node
class_name Player

signal on_player_head_area2d_entered(peer_id: int, player: Player, other: Area2D)
signal on_player_reset_complete(peer_id: int, player: Player)

@onready var head: Node2D = $Head
@onready var name_tag_root: Node2D = $NameTagRoot
@onready var marking_component: MarkingComponent = $MarkingComponent
@onready var move_component: MoveComponent = $MoveComponent
@onready var steering_component: SteeringComponent = $SteeringComponent

@export var steer_speed: float = 3.0
@export var move_speed: float = 100.0

var body_list: Array[Node2D] = []
var blink_tween: Tween
var initial_state: Dictionary = {}

# 씬 트리구조 진입
func _enter_tree() -> void:
	self.set_multiplayer_authority(self.name.to_int())

# 업데이트
func _process(_delta: float) -> void:
	name_tag_root.global_position = head.global_position + (Vector2.UP * 16)

# 플레이어 초기화
func initialize(player_data: Dictionary, state: Dictionary) -> void:
	$NameTagRoot/NameTag.text = player_data["name"]
	$Head/Face.modulate = player_data["face"]
	$Head/FaceOutline.modulate = player_data["outline"]
	$Head/FaceEye.modulate = player_data["eye"]
	$Head.global_position = state["location"]
	$Head.rotation = state["angle"]

	$BodySpawner.player = self

	# 초기 상태 저장
	initial_state["location"] = state["location"]
	initial_state["angle"] = state["angle"]

	# 몸체 리스트에 머리 추가
	self.body_list.append($Head)

# 몸체 추가 함수
@rpc("call_local", "any_peer")
func add_body(is_paused: bool) -> void:
	$BodySpawner.spawn({"peer_id": self.name.to_int(), "is_paused": is_paused})
	self._adjust_body_scale()

# 몸체 크기 조정
func _adjust_body_scale() -> void:
	var scale_array: Array[Vector2] = [
		Vector2.ONE * 0.5,
		Vector2.ONE * 0.6,
		Vector2.ONE * 0.7,
		Vector2.ONE * 0.8,
		Vector2.ONE * 0.9,
		Vector2.ONE * 1.0,
	]
	var scale_index: int = 0
	for i in range(self.body_list.size()-1, 0, -1):
		self.body_list[i].change_body_scale(scale_array[scale_index])
		scale_index += 1
		scale_index = clampi(scale_index, 0, scale_array.size()-1)

# 플레이어 이동 시작
@rpc("any_peer", "call_local")
func start_move() -> void:
	self._set_control_process_mode(Node.PROCESS_MODE_INHERIT)
	self._set_collision_disable(false)

	for i in range(1, self.body_list.size()):
		self.body_list[i].get_node("FollowComponent").process_mode = Node.PROCESS_MODE_INHERIT

# 플레이어 이동, 조작 중지
@rpc("any_peer", "call_local")
func stop_move() -> void:
	self._set_control_process_mode(Node.PROCESS_MODE_DISABLED)
	self._set_collision_disable(true)
	
	for i in range(1, self.body_list.size()):
		self.body_list[i].get_node("FollowComponent").process_mode = Node.PROCESS_MODE_DISABLED

# 머리 area2d 충돌 처리
func _on_head_area2d_entered(other_area: Area2D) -> void:
	on_player_head_area2d_entered.emit(self.name.to_int(), self, other_area)

# 플레이어 깜빡임 처리
@rpc("any_peer", "call_local")
func reset() -> void:
	var blink_time: float = 0.5
	var blink_count: int = 3
	# 반투명깜박임
	self.do_blink.rpc(blink_time, blink_count)
	# 이동, 조작 중지
	self._set_control_process_mode.rpc(Node.PROCESS_MODE_DISABLED)
	# 콜리전 비활성
	self._set_collision_disable.rpc(true)
	# 권한이 필요한 작업 처리
	await get_tree().create_timer(blink_time * blink_count).timeout
	# 머리를 제외한 몸체 제거
	self.clear_bodies()
	# 플레이어 위치 초기화
	self.reset_position()
	
	# 리셋 시그널 발동
	on_player_reset_complete.emit(self.name.to_int(), self)

# 몸체 모두 제거
@rpc("any_peer", "call_local")
func clear_bodies() -> void:
	# 머리를 제외한 몸체 제거
	var body_count: int = self.body_list.size()
	for i in range(body_count-1): # 몸체 목록에서 머리를 제외한 개수만큼 1번째것을 제거한다(리스트에서도 제거를 하므로)
		if is_multiplayer_authority(): # 실제 몸체 제거 함수 호출은 권한이 있는 피어만 수행하고 나머지는 body_list의 항목 제거만 수행
			var del_body = self.body_list[1]
			del_body.queue_free()
		self.body_list.remove_at(1)

# 플레이어 초기 위치로
@rpc("any_peer", "call_local")
func reset_position() -> void:
	if is_multiplayer_authority():
		# 초기위치로
		head.global_position = initial_state["location"]
		head.rotation = initial_state["angle"]

# 스프라이트 투명도 설정
@rpc("any_peer", "call_local")
func do_blink(blink_time: float, blink_count: int) -> void:
	if blink_tween:
		blink_tween.kill()
	blink_tween = get_tree().create_tween()
	blink_tween.set_loops(blink_count)
	blink_tween.tween_method(self._set_sprite_alpha_method, 1.0, 0.0, blink_time * 0.5)
	blink_tween.tween_method(self._set_sprite_alpha_method, 0.0, 1.0, blink_time * 0.5)

# 스프라이트 투명도 설정
func _set_sprite_alpha_method(alpha: float) -> void:
	var sprites = self.find_children("*", "Sprite2D", true, false)
	for sprite in sprites:
		sprite.modulate.a = alpha

# 이동, 조작 프로세싱 모드 설정
@rpc("any_peer", "call_local")
func _set_control_process_mode(mode: ProcessMode) -> void:
	self.move_component.process_mode = mode
	self.steering_component.process_mode = mode

# 콜리전 비활성화 여부 설정
@rpc("any_peer", "call_local")
func _set_collision_disable(is_disable: bool) -> void:
	var collisions = self.find_children("*", "CollisionShape2D", true, false)
	for collision in collisions:
		collision.set_deferred("disabled", is_disable)
		#collision.disabled = is_disable

# 이름에 해당하는 몸체 뒤부분 제거
@rpc("any_peer", "call_local")
func trim_body(body_name: String) -> void:
	var body_index: int = self._find_body_index(body_name)
	var del_count: int = self.body_list.size() - body_index
	for i in range(del_count):
		if is_multiplayer_authority():
			var del_body = self.body_list[body_index]
			del_body.queue_free()
		self.body_list.remove_at(body_index)

# 몸체 이름으로 body_list내 배열 인덱스 얻기
func _find_body_index(body_name: String) -> int:
	var find_index = -1
	
	for i in range(0, self.body_list.size()):
		if self.body_list[i].name == body_name:
			find_index = i
			break
			
	return find_index
