# FoodSpawner.gd
extends MultiplayerSpawner

const FOOD_ITEM_TEMPLATE = preload("res://Scenes/Templates/food_item.tscn")
@onready var foods_root: Node = $"../Foods"

var spawn_counter: int = 0

# 시작
func _ready() -> void:
	self.spawn_function = self._spawn_food
	self.despawned.connect(self._on_despawn_body)

func _on_despawn_body(node: Node) -> void:
	print_debug("FoodSPawner.gd _on_despawn_body -> ", node.name)
	
# 음식 스폰
func _spawn_food(_spawn_data: Dictionary) -> Node:
	
	var food = FOOD_ITEM_TEMPLATE.instantiate()
	food.name = "Food_" + str(spawn_counter)
	
	# 위치지정, 화면 가장자리에 너무 가까이에 생성되지 않도록 하기 위하여 공간여유를 좀 두고 생성한다
	var viewport_size: Vector2 = get_viewport().size
	food.global_position.x = randf_range(128.0, viewport_size.x - 128.0)
	food.global_position.y = randf_range(128.0, viewport_size.y - 128.0)
	
	spawn_counter += 1
	return food

# 음식 생성 타이머
func _on_timer_timeout() -> void:
	if multiplayer.is_server():
		if foods_root.get_child_count() < 10:
			self.spawn({})

# 모든 음식 제거
func clear_all_foods() -> void:
	for child in foods_root.get_children():
		child.queue_free()
