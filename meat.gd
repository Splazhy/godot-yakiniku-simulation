@tool
class_name Meat
extends Sprite2D

enum CookState {
	RAW,
	SLIGHTLY_COOKED,
	COOKED,
	CHARRED
}

const COOK_STATE_COLORS = {
	CookState.RAW: Color("#771212"),
	CookState.SLIGHTLY_COOKED: Color("#b15f5f"),
	CookState.COOKED: Color("#793e29"),
	CookState.BURNED: Color("#2d1e18"),
	CookState.CHARRED: Color("#171414")
}

@export_category("Meat Properties")
## The time it takes for the meat to go to the next cook state when on the grill (in seconds)
@export var cook_time: float = 3.0:
	set(value):
		timer.wait_time = value

@export_category("Meat State")
@export var front_side := CookState.RAW:
	set(value):
		if value == front_side:
			return
		front_side = value
		self_modulate = COOK_STATE_COLORS[front_side]

@export var back_side := CookState.RAW:
	set(value):
		if value == back_side:
			return
		back_side = value

@onready var timer: Timer = $Timer
@onready var area2d: Area2D = $Area2D
@onready var animation: AnimationPlayer = $AnimationPlayer

var _is_picked_up := false
var _is_on_grill := false
var _is_on_tray := false


## We assume that the meat spawns when player clicks on the meat tray,
## so the meat is always picked up when it spawns.
func _ready() -> void:
	_is_picked_up = true
	timer.timeout.connect(_on_cook_timer_timeout)
	area2d.input_event.connect(_handle_input)
	area2d.area_entered.connect(
		func(area: Area2D):
			if area.collision_layer == 0b100:
				_is_on_grill = true
			elif area.collision_layer == 0b010:
				_is_on_tray = true
	)
	area2d.area_exited.connect(
		func(area: Area2D):
			if area.collision_layer == 0b100:
				_is_on_grill = false
			elif area.collision_layer == 0b010:
				_is_on_tray = false
	)


func _on_cook_timer_timeout() -> void:
	back_side = min(back_side + 1, CookState.CHARRED)


func _handle_input(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is not InputEventMouseButton:
		return

	if not _is_picked_up \
		and event.button_index == MOUSE_BUTTON_RIGHT \
		and event.pressed:
		_flip()

	elif not _is_picked_up \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
		_pick_up()

	elif _is_picked_up \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and not event.pressed:
		_drop()


var _last_position: Vector2
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _is_picked_up:
		position = get_global_mouse_position()
		# Polish: rotate the meat to face the direction it's moving in.
		if position.distance_squared_to(_last_position) > 0.01:
			var new_rotation := position.direction_to(_last_position).angle()
			rotation = lerp_angle(rotation, new_rotation, _delta * 10)
		_last_position = position


func _pick_up() -> void:
	_is_picked_up = true
	timer.stop()


func _drop() -> void:
	_is_picked_up = false
	if _is_on_grill:
		timer.start()
	elif _is_on_tray:
		# Return the meat into the tray only if it's raw on both sides.
		if back_side == CookState.RAW and front_side == CookState.RAW:
			queue_free()


## Called when player right clicks on the meat to flip it.
func _flip() -> void:
	# Resets the cook timer when player flip while the meat is on the grill.
	if not timer.is_stopped():
		timer.start()
	animation.play("flip")


## For animation player
func flip() -> void:
	var temp = front_side
	front_side = back_side
	back_side = temp