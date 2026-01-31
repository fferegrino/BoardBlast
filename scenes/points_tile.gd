extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_values(bombs:int, points: int):
	$PointsLabel.text = "%02d" % points
	$BombsLabel.text = str(bombs)
