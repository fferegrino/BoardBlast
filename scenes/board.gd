extends Node2D

const Board = preload("res://game/board_generator.gd")
const CardLocation = preload("res://game/card_location.gd")
const Constants = preload("res://game/constants.gd")

signal card_clicked(card_position: CardLocation)

var _card_location_map: Dictionary = {}  # Maps "row,col" string to card nodes

func _get_location_key(row: int, column: int) -> String:
	return "%d,%d" % [row, column]

func _get_children_by_prefix(prefix: String) -> Array:
	var children = []
	for child in get_children():
		if child.name.begins_with(prefix):
			children.append(child)
	return children

func get_cards() -> Array:
	return _get_children_by_prefix(Constants.CARD_PREFIX)

func get_row_count_tiles() -> Array:
	return _get_children_by_prefix(Constants.ROW_TILE_PREFIX)

func get_column_count_tiles() -> Array:
	return _get_children_by_prefix(Constants.COLUMN_TILE_PREFIX)

func _get_card_location_from_name(card_name: String) -> CardLocation:
	# Extract row and column from card name (e.g., "t12" -> row=1, column=2)
	if card_name.length() >= 3 and card_name.begins_with(Constants.CARD_PREFIX):
		var row = int(card_name.substr(1, 1))
		var column = int(card_name.substr(2, 1))
		return CardLocation.new(row, column)
	return null

func get_card(row: int, column: int) -> Node:
	var key = _get_location_key(row, column)
	return _card_location_map.get(key, null)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_build_card_location_map()
	for card in get_cards():
		card.clicked.connect(_on_card_tapped)

func _build_card_location_map() -> void:
	_card_location_map.clear()
	for card in get_cards():
		var location = _get_card_location_from_name(card.name)
		if location != null:
			var key = _get_location_key(location.row, location.column)
			_card_location_map[key] = card

func set_board(board: Board) -> void:
	for card in get_cards():
		var location = _get_card_location_from_name(card.name)
		if location != null:
			card.set_card_value(board.grid[location.row][location.column])
			card.hide_all_marks()
			card.cover()
	
	var row_count_tiles = get_row_count_tiles()
	for row_index in range(row_count_tiles.size()):
		var row_tiles = row_count_tiles[row_index]
		row_tiles.set_values(board.zero_counts_per_row[row_index], board.sum_of_non_zero_per_row[row_index])

	var column_count_tiles = get_column_count_tiles()
	for column_index in range(column_count_tiles.size()):
		var column_tiles = column_count_tiles[column_index]
		column_tiles.set_values(board.zero_counts_per_column[column_index], board.sum_of_non_zero_per_column[column_index])

func _on_card_tapped(card: Node) -> void:
	var location = _get_card_location_from_name(card.name)
	if location != null:
		card_clicked.emit(location)

func toggle_mark(card_position: CardLocation, mark: int) -> void:
	var card = get_card(card_position.row, card_position.column)
	if card != null:
		card.toggle_mark(mark)

func set_card_discovered(card_position: CardLocation) -> void:
	var card = get_card(card_position.row, card_position.column)
	if card != null:
		card.set_discovered(true)

func set_targeted_card(card_position: CardLocation) -> void:
	for card in get_cards():
		card.set_target(false)
	if card_position != null:
		var selected_card = get_card(card_position.row, card_position.column)
		if selected_card != null:
			selected_card.set_target(true)
