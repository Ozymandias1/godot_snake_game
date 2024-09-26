extends Node

const CLICK_SFX = preload("res://Scenes/SFX/click.tscn")
const EAT_SFX = preload("res://Scenes/SFX/eat.tscn")
var audio_players: Dictionary = {}

# 시작
func _ready() -> void:
	# 버튼 클릭음
	var sfx = CLICK_SFX.instantiate()
	self.add_child(sfx)
	audio_players["Click"] = sfx
	
	# 먹을떄 사운드
	sfx = EAT_SFX.instantiate()
	self.add_child(sfx)
	audio_players["Eat"] = sfx

# 재생
@rpc("any_peer", "call_local")
func play(name_key: String) -> void:
	self.audio_players[name_key].play()
