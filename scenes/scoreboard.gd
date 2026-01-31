extends Node2D

@export var label_name: String = "Current level points"

func _ready() -> void:
	$Label.text = label_name

func set_score(score: int) -> void:
	if score < 0:
		score = 0
	$PointsLabel.text = "%05d" % score
