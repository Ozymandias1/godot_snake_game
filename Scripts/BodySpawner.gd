extends MultiplayerSpawner

const BODY_TEMPLATE = preload("res://Scenes/Templates/body.tscn")
var player: Player = null

func _ready() -> void:
	self.spawn_function = self._spawn_body

func _spawn_body(spawn_data: Dictionary) -> Node:
	var peer_id: int = spawn_data["peer_id"]
	var is_paused: bool = spawn_data["is_paused"]
	
	# 생성 위치 계산
	var last_body: Node2D = player.body_list.back()
	var last_body_front: Vector2 = last_body.global_transform.x
	var body_location: Vector2 = last_body.global_position + (-last_body_front * 32 / last_body.scale)
	
	var is_first_body: bool = player.get_node("Head") == last_body
	
	var body: Body = BODY_TEMPLATE.instantiate()
	body.name = player.name + "_Body_" + str(player.body_list.size())
	body.initialize(peer_id, player.get_node("Head/Face").modulate, player.get_node("Head/FaceOutline").modulate, body_location, is_first_body)
	body.look_at(last_body.global_position)
	player.body_list.append(body)
	
	# FollowComponent 목표 객체 설정
	var follow_Component: FollowComponent = body.get_node("FollowComponent")
	follow_Component.follow_target = last_body
	follow_Component.player = player
	
	if is_paused:
		follow_Component.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		follow_Component.process_mode = Node.PROCESS_MODE_INHERIT
	
	player.marking_component.on_marking.connect(follow_Component.update_target_position)
	player.marking_component.on_marking.emit()
	
	return body
