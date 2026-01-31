class_name GameState

const CardLocation = preload("res://game/card_location.gd")
const Constants = preload("res://game/constants.gd")

var discovered_cards: Dictionary  # Dictionary of "row,col" -> true for discovered cards
var current_points: int  # Current points the user has
var session_points: int  # Points the user has accumulated in the current session
var current_level: int  # Current level being played
var board: Board  # Reference to the current board
var moves_count: int  # Number of card discoveries/moves made

func _init(level: int, game_board: Board, sess_points: int):
	current_level = level
	board = game_board
	current_points = Constants.INITIAL_POINTS
	session_points = sess_points
	moves_count = 0
	discovered_cards = {}

# Mark a card as discovered
func discover_card(card_position: CardLocation) -> void:
	var key = str(card_position.row) + "," + str(card_position.column)
	if not discovered_cards.has(key):
		discovered_cards[key] = true
		moves_count += 1
		add_points(board.grid[card_position.row][card_position.column])

# Check if a card is discovered
func is_card_discovered(card_position: CardLocation) -> bool:
	var key = str(card_position.row) + "," + str(card_position.column)
	return discovered_cards.has(key)

# Add points to the current score
func add_points(points: int) -> void:
	if current_points == Constants.INITIAL_POINTS:
		current_points = 1
	current_points *= points

func won_game() -> bool:
	return current_points >= board.total_winning_points

func lost_game() -> bool:
	return current_points == 0

# Get the number of discovered cards
func get_discovered_count() -> int:
	return discovered_cards.size()

# Check if all cards have been discovered
func are_all_cards_discovered() -> bool:
	if board == null:
		return false
	var total_cards = board.grid.size() * board.grid[0].size()
	return discovered_cards.size() >= total_cards

# Reset the game state for a new level
func reset_for_level(level: int, game_board: Board) -> void:
	current_level = level
	board = game_board
	discovered_cards.clear()
	moves_count = 0
	# Note: current_points is preserved across levels
