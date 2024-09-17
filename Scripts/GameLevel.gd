# GameLevel.gd
extends Node

@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var btn_start_game: Button = $UI/BtnStartGame
@onready var players: Node = $Players
@onready var label_timer_root: Node2D = $UI/LabelTimerRoot
@onready var label_timer: Label = $UI/LabelTimerRoot/LabelTimer
@onready var start_game_timer: Timer = $UI/StartGameTimer
@onready var food_spawn_timer: Timer = $FoodSpawner/Timer

var start_game_remain_time: int = 4
var remain_time_tween: Tween = null

# 시작
func _ready() -> void:
	# 타이머 텍스트 중앙 위치
	var viewport_rect = get_viewport().size
	label_timer_root.global_position = Vector2(viewport_rect.x * 0.5, viewport_rect.y * 0.5)

	# 시작버튼 숨김
	btn_start_game.visible = multiplayer.is_server()

	# 서버일경우
	if multiplayer.is_server():
		NetworkManager.on_player_connected.connect(self._on_player_connected)
		self._on_player_connected(1, NetworkManager.my_player_data)

# 플레이어 접속 처리
func _on_player_connected(peer_id: int, player_data: Dictionary) -> void:
	var player = player_spawner.spawn({
		"peer_id": peer_id,
		"player_data": player_data
	})

	# 플레이어 생성시 몸체 3개 생성
	await get_tree().create_timer(0.1).timeout
	player.add_body.rpc_id(peer_id, true)
	await get_tree().create_timer(0.1).timeout
	player.add_body.rpc_id(peer_id, true)
	await get_tree().create_timer(0.1).timeout
	player.add_body.rpc_id(peer_id, true)
	
	# 플레이어 머리 충돌 처리 시그널 처리 등록
	player.on_player_head_area2d_entered.connect(self.on_player_head_area2d_entered)

# 게임 시작 버튼
func _on_btn_start_game_pressed() -> void:
	self.food_spawn_timer.start()
	self.btn_start_game.hide()
	self.start_game_timer.start()
	self._on_start_game_timer_timeout()

# 게임 시작 타이머
func _on_start_game_timer_timeout() -> void:
	self.label_timer.visible = true

	start_game_remain_time -= 1
	if start_game_remain_time == 0:
		self.label_timer.text = "Game Started"
		self.label_timer_root.scale = Vector2(1.3, 1.3)
		self._do_remain_time_animation(true)
		self.start_game_timer.stop()
	else:
		self.label_timer.text = str(start_game_remain_time)
		self.label_timer_root.scale = Vector2(1.3, 1.3)
		self._do_remain_time_animation()

# 게임 시작 타이머 텍스트 애니메이션
func _do_remain_time_animation(is_hide: bool = false) -> void:
	if remain_time_tween:
		remain_time_tween.kill()
	remain_time_tween = get_tree().create_tween()
	remain_time_tween.set_ease(Tween.EASE_IN_OUT)
	remain_time_tween.set_trans(Tween.TRANS_EXPO)
	remain_time_tween.tween_property(self.label_timer_root, "scale", Vector2.ONE, 0.5)
	if is_hide:
		remain_time_tween.tween_property(self.label_timer, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
		remain_time_tween.tween_callback(self._start_game.rpc)

# 게임 시작
@rpc("any_peer", "call_local")
func _start_game() -> void:
	for player in players.get_children():
		player.start_move()

# 플레이어 머리 충돌 처리
func on_player_head_area2d_entered(peer_id: int, player: Player, other: Area2D) -> void:
	var is_food_item: bool = other.get_meta("is_food_item", false)
	if is_food_item:
		player.add_body.rpc_id(peer_id, false)
		other.queue_free.call_deferred()
