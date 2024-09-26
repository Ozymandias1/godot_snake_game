extends Node

var audio_players: Dictionary = {}

# 시작
func _ready() -> void:
	# 버튼 클릭음 초기화
	var player = AudioStreamPlayer.new()
	var stream = load("res://Audio/metalLatch.ogg")
	player.stream = stream
	self.add_child(player)
	audio_players["Click"] = player

# 재생
func play(name_key: String) -> void:
	self.audio_players[name_key].play()
