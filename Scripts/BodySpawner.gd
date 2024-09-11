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
	
	var body = BODY_TEMPLATE.instantiate()
	body.set_multiplayer_authority(peer_id)
	body.name = player.name + "_Body_" + str(player.body_list.size())
	body.global_position = body_location
	player.body_list.append(body)
	
	return body
