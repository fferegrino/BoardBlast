extends Node2D

signal close_button_clicked(button)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_replay_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		close_button_clicked.emit(self)
