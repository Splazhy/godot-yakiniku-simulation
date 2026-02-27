class_name MeatTray
extends Sprite2D

@onready var area2d: Area2D = $Area2D
@export var meat_scene: PackedScene

## Lets the parent node take care of instantiating the meat
## when the player clicks on the meat tray.
signal meat_picked_up(meat_scene: PackedScene)


func _ready() -> void:
	area2d.input_event.connect(_handle_input)


func _handle_input(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		meat_picked_up.emit(meat_scene)