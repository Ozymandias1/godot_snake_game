extends MultiplayerSpawner

const BODY_TEMPLATE = preload("res://Scenes/Templates/body.tscn")
var player: Player = null

func _ready() -> void:
	self.spawn_function = self._spawn_body

func _spawn_body(spawn_data: Dictionary) -> Node:
	var peer_id: int = spawn_data["peer_id"]

	# 생성 위치 계산
	var last_body: Node2D = player.body_list.back()
	var last_body_front: Vector2 = last_body.global_transform.x
	var body_location: Vector2 = last_body.global_position + (-last_body_front * 32)
	
	var body: Body = BODY_TEMPLATE.instantiate()
	body.name = player.name + "_Body_" + str(player.body_list.size())
	body.initialize(peer_id, player.get_node("Head/Face").modulate, player.get_node("Head/FaceOutline").modulate, body_location)
	body.look_at(last_body.global_position)
	player.body_list.append(body)
	
	return body
