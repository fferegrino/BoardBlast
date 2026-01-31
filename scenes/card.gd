extends Node2D

signal clicked(child)

@onready var all_marks: Array[Sprite2D] = [$mark0, $mark1, $mark2, $mark3]

var card_value: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $Number:
		$Number.visible = false
	if $Target:
		$Target.visible = false
	hide_all_marks()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(self)
		
func toggle_mark(mark):
	all_marks[mark].visible = not all_marks[mark].visible

func hide_all_marks():
	for mark in all_marks:
		mark.visible = false

func set_target(on) -> void:
	if not $Target:
		return
	if on == true:
		$Target.visible = true
		$Target.play("default")
	else:
		$Target.visible = false
		$Target.stop()
	
		
func cover():
	if $Number:
		$Number.visible = false
	if $Animation:
		$Animation.play("default")
		$Explosion.visible = false

func set_discovered(_discovered: bool):
	hide_all_marks()
	if $Number:
		$Number.visible = true
	if $Animation:
		$Animation.play("break")
		if card_value == 0:
			$Explosion.visible = true
			$Explosion.play("default")

func set_card_value(value):
	if $Number:
		card_value = value
		$Number.set_frame(value)
