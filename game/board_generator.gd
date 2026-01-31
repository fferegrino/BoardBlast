class_name Board

const CardLocation = preload("res://game/card_location.gd")
const Constants = preload("res://game/constants.gd")

var grid: Array  # The 2D array representing the board
var zero_counts_per_row: Array  # Number of 0s in each row
var zero_counts_per_column: Array  # Number of 0s in each column
var multiplied_non_zero_per_row: Array  # Multiplication of all non-zero values in each row
var multiplied_non_zero_per_column: Array  # Multiplication of all non-zero values in each column
var sum_of_non_zero_per_row: Array  # Sum of all non-zero values in each row
var sum_of_non_zero_per_column: Array  # Sum of all non-zero values in each column
var total_winning_points: int # Total points for the board
var zeroes_locations: Array # Array of CardLocation for all zeroes

func _init(board_grid: Array):
	grid = board_grid
	_calculate_stats()

func _calculate_stats() -> void:
	var rows = grid.size()
	var cols = grid[0].size() if rows > 0 else 0
	
	# Initialize arrays
	zero_counts_per_row = []
	zero_counts_per_column = []
	sum_of_non_zero_per_row = []
	sum_of_non_zero_per_column = []
	multiplied_non_zero_per_row = []
	multiplied_non_zero_per_column = []
	total_winning_points = 1
	zeroes_locations = []
	# Calculate row statistics
	for row in range(rows):
		var zero_count = 0
		var product = 1
		var sum = 0
		for col in range(cols):
			var value = grid[row][col]
			if value == 0:
				zero_count += 1
				zeroes_locations.append(CardLocation.new(row, col))
			else:
				product *= value
				sum += value
		total_winning_points *= product
		zero_counts_per_row.append(zero_count)
		multiplied_non_zero_per_row.append(product)
		sum_of_non_zero_per_row.append(sum)
	
	# Calculate column statistics
	for col in range(cols):
		var zero_count = 0
		var product = 1
		var sum = 0
		for row in range(rows):
			var value = grid[row][col]
			if value == 0:
				zero_count += 1
			else:
				product *= value
				sum += value
		zero_counts_per_column.append(zero_count)
		multiplied_non_zero_per_column.append(product)
		sum_of_non_zero_per_column.append(sum)

# Getter methods for convenience
func get_cell(row: int, col: int) -> int:
	return grid[row][col]

func get_row(row: int) -> Array:
	return grid[row]

func get_column(col: int) -> Array:
	var column = []
	for row in range(grid.size()):
		column.append(grid[row][col])
	return column


const CLASSIC_LEVELS = {
	"1": [
		[24, 3, 1, 6],
		[27, 0, 3, 6],
		[32, 5, 0, 6],
		[36, 2, 2, 6],
		[48, 4, 1, 6]
	],
	"2": [
		[54, 1, 3, 7],
		[64, 6, 0, 7],
		[72, 3, 2, 7],
		[81, 0, 4, 7],
		[96, 5, 1, 7]
	],
	"3": [
		[108, 2, 3, 8],
		[128, 7, 0, 8],
		[144, 4, 2, 8],
		[162, 1, 4, 8],
		[192, 6, 1, 8]
	],
	"4": [
		[216, 3, 3, 8],
		[243, 0, 5, 8],
		[256, 8, 0, 10],
		[288, 5, 2, 10],
		[324, 2, 4, 10]
	],
	"5": [
		[384, 7, 1, 10],
		[432, 4, 3, 10],
		[486, 1, 5, 10],
		[512, 9, 0, 10],
		[576, 6, 2, 10]
	],
	"6": [
		[648, 3, 4, 10],
		[729, 0, 6, 10],
		[768, 8, 1, 10],
		[864, 5, 3, 10],
		[972, 2, 5, 10]
	],
	"7": [
		[1152, 7, 2, 10],
		[1296, 4, 4, 10],
		[1458, 1, 6, 13],
		[1536, 9, 1, 13],
		[1728, 6, 3, 10]
	],
	"8": [
		[2187, 0, 7, 10],
		[2304, 8, 2, 10],
		[2592, 5, 4, 10],
		[2916, 2, 6, 10],
		[3456, 7, 3, 10]
	],
}

static func generate_board(level: int) -> Board:
	var level_data = CLASSIC_LEVELS[str(level)]
	var selected_row = level_data[randi() % level_data.size()]
	
	var count_zeros = selected_row[3]
	var count_twos = selected_row[1]
	var count_threes = selected_row[2]
	var count_ones = Constants.TOTAL_CELLS - count_threes - count_zeros - count_twos
	
	var cells = []
	# Add zeros
	for i in range(count_zeros):
		cells.append(0)
	# Add ones
	for i in range(count_ones):
		cells.append(1)
	# Add twos
	for i in range(count_twos):
		cells.append(2)
	# Add threes
	for i in range(count_threes):
		cells.append(3)
	
	# Shuffle the cells
	cells.shuffle()
	
	# Create board with specified width
	var board = []
	for i in range(0, cells.size(), Constants.BOARD_WIDTH):
		board.append(cells.slice(i, i + Constants.BOARD_WIDTH))
	
	return Board.new(board)
