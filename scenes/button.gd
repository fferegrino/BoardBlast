extends Node2D

@export var VIEW_SPRITE: int = 0
@export var IS_TOGGLE: bool = false
@export var STARTING_VALUE: bool = false

var toggled: bool = false

signal button_tapped(button)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not IS_TOGGLE:
		$ButtonOpts.frame_coords = Vector2i(VIEW_SPRITE, 0)
	else:
		set_toggled(STARTING_VALUE)

func set_toggled(value: bool) -> void:
	toggled = value
	$ButtonOpts.frame_coords = Vector2i(VIEW_SPRITE, 0) if value else Vector2i(VIEW_SPRITE, 1)

func is_toggled() -> bool:
	return toggled


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		button_tapped.emit(self)
