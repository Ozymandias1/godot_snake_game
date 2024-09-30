# BodySpawner.gd
extends MultiplayerSpawner

const BODY_TEMPLATE = preload("res://Scenes/Templates/body.tscn")
var player: Player = null

# 시작
func _ready() -> void:
	self.spawn_function = self._spawn_body

# 몸체 스폰 함수
func _spawn_body(spawn_data: Dictionary) -> Node:
	var peer_id: int = spawn_data["peer_id"]
	var is_paused: bool = spawn_data["is_paused"]
	
	# 생성 위치 계산
	var last_body: Node2D = self.player.body_list.back()
	var last_body_front: Vector2 = last_body.global_transform.x
	var body_location: Vector2 = last_body.global_position + (-last_body_front * 32 / last_body.scale)
	
	# 처음 추가되는 몸체인지 판별 여부
	var is_first_body: bool = self.player.get_node("Head") == last_body
	
	var body: Body = BODY_TEMPLATE.instantiate()
	body.name = self.player.name + "_Body_" + str(self.player.body_list.size())
	body.initialize(peer_id, self.player.get_node("Head/Face").modulate, self.player.get_node("Head/FaceOutline").modulate, body_location, is_first_body)
	body.look_at(last_body.global_position)
	self.player.body_list.append(body)
	
	# FollowComponent 목표 객체 설정
	var follow_Component: FollowComponent = body.get_node("FollowComponent")
	follow_Component.follow_target = last_body
	follow_Component.player = self.player
	
	if is_paused:
		follow_Component.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		follow_Component.process_mode = Node.PROCESS_MODE_INHERIT
	
	self.player.marking_component.on_marking.connect(follow_Component.update_target_position)
	self.player.marking_component.on_marking.emit()
	
	return body
