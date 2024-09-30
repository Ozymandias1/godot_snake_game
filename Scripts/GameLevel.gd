# GameLevel.gd
extends Node

@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var btn_start_game: Button = $UI/BtnStartGame
@onready var players: Node = $Players
@onready var label_timer_root: Node2D = $UI/LabelTimerRoot
@onready var label_timer: Label = $UI/LabelTimerRoot/LabelTimer
@onready var start_game_timer: Timer = $UI/StartGameTimer
@onready var food_spawn_timer: Timer = $FoodSpawner/Timer
@onready var food_spawner: MultiplayerSpawner = $FoodSpawner
@onready var score_board_item_spawner: MultiplayerSpawner = $UI/ScoreBoard/ScoreBoardItemSpawner
@onready var label_remain_time: Label = $UI/LabelRemainTime
@onready var gameplay_timer: Timer = $UI/LabelRemainTime/GameplayTimer
@onready var result: Control = $UI/Result
@onready var label_result_score: Label = $UI/Result/PanelContainer/LabelResultScore
@onready var btn_restart: Button = $UI/Result/BtnRestart

var start_game_remain_time: int = 4
var remain_time_tween: Tween = null
var scores: Dictionary = {}
var gameplay_time_seconds: int = 5 * 60

# 시작
func _ready() -> void:
	# 타이머 텍스트 중앙 위치
	var viewport_rect = get_viewport().size
	label_timer_root.global_position = Vector2(viewport_rect.x * 0.5, viewport_rect.y * 0.5)

	# 서버가 아닐 경우 시작버튼 숨김
	btn_start_game.visible = multiplayer.is_server()

	# 서버일경우
	if multiplayer.is_server():
		NetworkManager.on_player_connected.connect(self._on_player_connected)
		NetworkManager.on_player_disconnected.connect(self._on_player_disconnected)
		self._on_player_connected(1, NetworkManager.my_player_data)

# 플레이어 접속 처리
func _on_player_connected(peer_id: int, player_data: Dictionary) -> void:
	var player = player_spawner.spawn({
		"peer_id": peer_id,
		"player_data": player_data
	})

	# 플레이어 생성시 몸체 3개 생성
	await self._add_initial_player_bodies(3, player)
	player.adjust_body_scale.rpc()

	# 플레이어 머리 충돌 처리 시그널 처리 등록
	player.on_player_head_area2d_entered.connect(self._on_player_head_area2d_entered)
	player.on_player_reset_complete.connect(self._on_player_reset_complete)

	# 점수판
	scores[peer_id] = 0
	score_board_item_spawner.spawn({
		"peer_id": peer_id,
		"player_data": player_data
	})

# 플레이어 접속 종료 처리
func _on_player_disconnected(peer_id: int) -> void:
	# 플레이어 제거
	var del_player: Player = players.get_node(str(peer_id))
	# 시그널 연결 해제
	del_player.on_player_head_area2d_entered.disconnect(self._on_player_head_area2d_entered)
	del_player.on_player_reset_complete.disconnect(self._on_player_reset_complete)
	# 제거
	del_player.queue_free.call_deferred()
	
	# 점수판 제거
	scores.erase(peer_id)
	score_board_item_spawner.delete_scoreboard_item(peer_id)

# 게임 시작 버튼
func _on_btn_start_game_pressed() -> void:
	SfxManager.play("Click")
	self.food_spawn_timer.start()
	self.btn_start_game.hide()
	self.start_game_timer.start()
	self._on_start_game_timer_timeout()

# 게임 시작 타이머
func _on_start_game_timer_timeout() -> void:
	self.label_timer.visible = true

	start_game_remain_time -= 1
	if start_game_remain_time == 0:
		SfxManager.play.rpc("Begin")
		self.label_timer.text = "Game Started"
		self.label_timer_root.scale = Vector2(1.3, 1.3)
		self._do_remain_time_animation(true)
		self.start_game_timer.stop()
	else:
		SfxManager.play.rpc(str(start_game_remain_time))
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
	gameplay_timer.start()

# 게임 중지
@rpc("any_peer", "call_local")
func _stop_game() -> void:
	for player in players.get_children():
		player.stop_move()
	gameplay_timer.stop()

# 플레이어 머리 충돌 처리
func _on_player_head_area2d_entered(peer_id: int, player: Player, other: Area2D) -> void:
	var is_food_item: bool = other.get_meta("is_food_item", false)
	if is_food_item:
		SfxManager.play.rpc_id(peer_id, "Eat")
		player.add_body.rpc_id(peer_id, false)
		other.queue_free.call_deferred()
		# 점수
		if result.visible == false: # 결과창이 보이는 상태에서는 점수 증가를 하지 않음
			self.scores[peer_id] += 1
			self.score_board_item_spawner.set_score(peer_id, scores[peer_id])
			self.score_board_item_spawner.create_score_fx.rpc_id(peer_id, peer_id, 1)
	else:
		player.reset.rpc()
		# 충돌한 객체의 부모노드가 Body타입이라면 다른 플레이어의 몸체에 충돌한 것이므로
		var other_player_body = other.get_parent()
		if is_instance_of(other_player_body, Body):
			self.scores[other_player_body.peer_id] += 5 # 충돌을 유발한 플레이어에게 5점 부여
			self.score_board_item_spawner.set_score(other_player_body.peer_id, scores[other_player_body.peer_id])
			self.score_board_item_spawner.create_score_fx.rpc_id(other_player_body.peer_id, other_player_body.peer_id, 5)
			
			var other_player = self.players.get_node(str(other_player_body.peer_id))
			if other_player != null:
				other_player.trim_body.rpc(other_player_body.name)
				other_player.adjust_body_scale.rpc()

# 플레이어 리셋 완료 처리
func _on_player_reset_complete(_peer_id: int, player: Player) -> void:
	await self._add_initial_player_bodies(3, player)
	await get_tree().create_timer(0.1).timeout
	player.start_move.rpc()

# 게임플레이 타이머
func _on_gameplay_timer_timeout() -> void:
	gameplay_time_seconds -= 1

	# 게임 진행시간이 다되면 점수를 높은순서로 취합하여 텍스트로 보여준다
	if gameplay_time_seconds == 0:
		SfxManager.play.rpc("GameOver")
		label_result_score.text = "Game Over"
		var results: Array[ScoreBoardItem] = score_board_item_spawner.get_results()
		for item in results:
			label_result_score.text += "\n" + item.get_score_text()
		result.visible = true
		btn_restart.visible = multiplayer.is_server()
		self._stop_game.rpc()

	# 남은시간 텍스트 설정
	var seconds = gameplay_time_seconds % 60
	var minutes = (int)(gameplay_time_seconds / 60.0) % 60
	var timer_string = "%02d:%02d" % [minutes, seconds] # 텍스트를 분:초 형식으로 표현
	label_remain_time.text = timer_string

# 재시작 버튼 클릭
func _on_btn_restart_pressed() -> void:
	SfxManager.play("Click")
	# 플레이어 초기화
	for player in players.get_children():
		player.stop_move.rpc()
		player.clear_bodies.rpc()
		player.reset_position.rpc()

		self._add_initial_player_bodies(3, player)

	# 음식 모두 제거
	food_spawner.clear_all_foods()

	# 점수 초기화
	for peer_id in scores.keys():
		scores[peer_id] = 0
		self.score_board_item_spawner.set_score(peer_id, scores[peer_id])

	# 시간 및 기타 시작 루틴
	result.visible = false
	start_game_remain_time = 4
	gameplay_time_seconds = 5 * 60
	self.label_timer.modulate = Color(1, 1, 1, 1)
	self.start_game_timer.start()
	self._on_start_game_timer_timeout()

# 몸체 추가 함수
func _add_initial_player_bodies(count: int, player: Player) -> void:
	for i in range(0, count):
		await get_tree().create_timer(0.1).timeout
		player.add_body.rpc_id(player.name.to_int(), true)
