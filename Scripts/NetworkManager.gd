# NetworkManager.gd
extends Node

signal on_player_connected(peer_id: int, player_data: Dictionary)
signal on_player_disconnected(peer_id: int)

signal on_server_connection_ok
signal on_server_connection_failed

var my_player_data: Dictionary = {}

var server_info: Dictionary = {}
var broadcaster: PacketPeerUDP
var broadcast_bind_port: int = 15000
var broadcast_listener: PacketPeerUDP
var broadcast_listen_port: int = 15001

signal on_get_server_info_finished
signal on_server_detected(ip: String, server_info: Dictionary)

# 시작
func _ready() -> void:
	multiplayer.connected_to_server.connect(self._on_connected_to_server)
	multiplayer.peer_disconnected.connect(self._on_peer_disconnected)
	multiplayer.server_disconnected.connect(self._on_server_disconnected)

	multiplayer.connected_to_server.connect(self._on_connection_ok)
	multiplayer.connection_failed.connect(self._on_connection_failed)

# 서버 접속 성공
func _on_connected_to_server() -> void:
	# 서버 접속 성공시 서버로(peer_id->1) 내 플레이어 정보를 전송한다
	self.receive_player_data.rpc_id(1, self.my_player_data)

# 플레이어 접속 해제 시그널
func _on_peer_disconnected(peer_id: int) -> void:
	self.on_player_disconnected.emit(peer_id)

# 서버 접속 종료 시그널
func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	#OS.alert("서버가 게임을 종료하였습니다.", "게임종료")
	#get_tree().quit()

# 접속한 피어로부터 플레이어 정보 수신
@rpc("any_peer", "call_local")
func receive_player_data(player_data: Dictionary) -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	self.on_player_connected.emit(peer_id, player_data)

# 서버 생성
func create_server(server_name: String, port: int) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error:
		printerr("NetworkManager.gd create_server() -> ", error)

 	# 서버 정보 저장
	server_info["name"] = server_name
	server_info["gameplay_port"] = port

	multiplayer.multiplayer_peer = peer
	self.on_player_connected.emit(1, self.my_player_data)
	# 서버 정보 방송 시작
	self._start_broadcast()

# 서버조인
func join_server(ip: String, port: int) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error:
		printerr("NetworkManager.gd join_server() -> ", error)

	peer.get_peer(1).set_timeout(0, 0, 5000) # 5초내 접속안되면 실패처리하기 위한 설정

	multiplayer.multiplayer_peer = peer

# 서버 접속 성공
func _on_connection_ok() -> void:
	on_server_connection_ok.emit()

# 서버 접속 실패
func _on_connection_failed() -> void:
	on_server_connection_failed.emit()

# 서버 방송을 위한 로컬 ipv4 주소를 얻는다.
func _get_local_ipv4_address():
	# OS.get_environment사용시 플랫폼 별로 다른 파라미터를 사용해야 하는것으로 보임.(https://forum.godotengine.org/t/how-to-get-local-ip-address/10399)
	# 윈도우에선 환경변수 COMPUTERNAME을 사용
	var ipv4_address = IP.resolve_hostname(OS.get_environment("COMPUTERNAME"), IP.TYPE_IPV4)
	return ipv4_address

# 주어진 ip주소를 브로드캐스트 ip주소로 변환한다.
func _get_broadcast_address(server_ip: String):
	var ip_split = server_ip.split(".")
	return "%s.%s.%s.255" % [ip_split[0], ip_split[1], ip_split[2]]

# 서버 정보 방송 시작
func _start_broadcast() -> void:
	# 브로드캐스터를 생성하고 연결된 네트워크상의 장비들에게
	# 나의 서버정보 방송을 위해 끝자리 주소를 255로 설정한다.
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	var local_ipv4_addr = self._get_local_ipv4_address()
	var broadcast_server_ip = self._get_broadcast_address(local_ipv4_addr)
	broadcaster.set_dest_address(broadcast_server_ip, broadcast_listen_port)

	var is_succeeded = broadcaster.bind(broadcast_bind_port) # 브로드캐스트로 바인딩
	if is_succeeded == OK:
		# 지정한 포트로 브로드캐스터 바인딩이 성공하면
		# 1초간격으로 서버 정보 방송을 위해 타이머를 생성하여 처리한다.
		var broadcast_timer: Timer = Timer.new()
		broadcast_timer.timeout.connect(self._on_timeout_broadcast_my_server_info)
		broadcast_timer.wait_time = 1.0
		broadcast_timer.autostart = true
		broadcast_timer.one_shot = false
		add_child(broadcast_timer)
	else:
		printerr("브로드캐스터 바인딩 실패")

# 내 서버 정보 방송 타이머 콜백
func _on_timeout_broadcast_my_server_info():
	# 서버 정보를 utf8 버퍼로 변환하여 패킷으로 처리
	var broadcast_data: String = JSON.stringify(server_info)
	var broadcast_packet: PackedByteArray = broadcast_data.to_utf8_buffer()
	broadcaster.put_packet(broadcast_packet)

# 리스너 닫기
func _close_listener():
	if broadcast_listener != null:
		broadcast_listener.close()
		broadcast_listener = null


func start_get_server_info():
	self._close_listener()
	broadcast_listener = PacketPeerUDP.new()
	var is_succeeded = broadcast_listener.bind(broadcast_listen_port) # 리슨포트로 바인딩
	if is_succeeded == OK:
		# 리슨포트로 바인딩이 성공하면 타이머를 생성하여 5초동안 연결된 네트워크상에 생성된 서버정보를 얻는다.
		var listener_timer: Timer = Timer.new()
		listener_timer.timeout.connect(self._on_timeout_listening_server_info)
		listener_timer.wait_time = 5.0
		listener_timer.autostart = true
		listener_timer.one_shot = true
		add_child(listener_timer)
	else:
		printerr("리스너 바인딩 실패")

# 서버 정보 얻는 리스너 타이머 아웃 콜백
func _on_timeout_listening_server_info():
	self._close_listener()
	self.on_get_server_info_finished.emit()

# 스크립트 업데이트
func _process(_delta):
	# 매 프레임마다 리스너가 유효하면 가져올 서버 정보가 있는지 체크하여 처리한다.
	if broadcast_listener and broadcast_listener.get_available_packet_count() > 0:
		var server_ip: String = broadcast_listener.get_packet_ip()
		var _port: int = broadcast_listener.get_packet_port()
		var data_bytes: PackedByteArray = broadcast_listener.get_packet()
		var data: String = data_bytes.get_string_from_utf8()
		var receive_server_info: Dictionary = JSON.parse_string(data)
		self.on_server_detected.emit(server_ip, receive_server_info)
