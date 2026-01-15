extends Node

@onready var score_label: Label = $"../Label"
var score: int = 0

func add_score(points: int):
	score += points
	score_label.text = "%d" % score
