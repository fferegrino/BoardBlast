class_name CardLocation

var row: int
var column: int

func _init(r: int, c: int):
	row = r
	column = c

func _is_equal(other) -> bool:
	if other is CardLocation:
		return row == other.row and column == other.column
	return false
