# SFXManager.gd
extends Node

const CLICK_SFX = preload("res://Scenes/SFX/click.tscn")
const EAT_SFX = preload("res://Scenes/SFX/eat.tscn")
const COUNT_1_SFX = preload("res://Scenes/SFX/count_1.tscn")
const COUNT_2_SFX = preload("res://Scenes/SFX/count_2.tscn")
const COUNT_3_SFX = preload("res://Scenes/SFX/count_3.tscn")
const BEGIN_SFX = preload("res://Scenes/SFX/begin.tscn")
const GAME_OVER_SFX = preload("res://Scenes/SFX/game_over.tscn")
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

	# 카운트다운
	sfx = COUNT_3_SFX.instantiate()
	self.add_child(sfx)
	audio_players["3"] = sfx

	sfx = COUNT_2_SFX.instantiate()
	self.add_child(sfx)
	audio_players["2"] = sfx

	sfx = COUNT_1_SFX.instantiate()
	self.add_child(sfx)
	audio_players["1"] = sfx

	sfx = BEGIN_SFX.instantiate()
	self.add_child(sfx)
	audio_players["Begin"] = sfx

	# 게임오버
	sfx = GAME_OVER_SFX.instantiate()
	self.add_child(sfx)
	audio_players["GameOver"] = sfx

# 재생
@rpc("any_peer", "call_local")
func play(name_key: String) -> void:
	self.audio_players[name_key].play()
