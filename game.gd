extends Node2D

var _meat_trays: Array[MeatTray] = []


func _ready() -> void:
	for child in get_children():
		if child is MeatTray:
			_meat_trays.append(child)
			child.meat_picked_up.connect(_on_meat_picked_up)


func _on_meat_picked_up(meat_scene: PackedScene) -> void:
	var meat_instance = meat_scene.instantiate()
	add_child(meat_instance)