extends Node2D



@export var PLAY_MUSIC: bool = false
const BoardGenerator = preload("res://game/board_generator.gd")
const GameState = preload("res://game/game_state.gd")
const CardLocation = preload("res://game/card_location.gd")
const Constants = preload("res://game/constants.gd")

var current_game_state: GameState
var targeted_card: CardLocation = null
var is_info_screen_visible: bool = false
var sfx_enabled: bool = true
var music_enabled: bool = false
@onready var board = $Canvas/Board
@onready var total_points = $Canvas/TotalPoints
@onready var level_points = $Canvas/LevelPoints
@onready var end_screen = $Canvas/EndScreen
@onready var win_screen = $Canvas/WinScreen
@onready var info_screen = $Canvas/InfoScreen
@onready var level_display = $Canvas/LevelDisplay
@onready var mark_board = $Canvas/MarkBoard
@onready var sound_button = $Canvas/SoundButton
@onready var music_button = $Canvas/MusicButton
@onready var info_button = $Canvas/InfoButton

# ============================================================================
# Initialization
# ============================================================================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not board or not end_screen or not win_screen:
		push_error("Required nodes not found in scene tree")
		return
	
	board.card_clicked.connect(_on_card_clicked)
	end_screen.replay_clicked.connect(_on_replay_clicked)
	win_screen.next_level_clicked.connect(_on_next_level_clicked)
	mark_board.mark_board_tapped.connect(_on_mark_board_tapped)
	sound_button.button_tapped.connect(_on_sound_button_tapped)
	music_button.button_tapped.connect(_on_music_button_tapped)
	info_button.button_tapped.connect(_on_info_button_tapped)
	# Initial audio state
	sfx_enabled = true
	music_enabled = PLAY_MUSIC

	sound_button.set_toggled(sfx_enabled)
	music_button.set_toggled(music_enabled)

	AudioManager.set_sfx_enabled(sfx_enabled)
	AudioManager.set_music_enabled(music_enabled)
	if music_enabled:
		AudioManager.play_music("bg", "mp3")

	start_new_game(Constants.STARTING_LEVEL, 0)

func start_new_game(level: int, session_points: int) -> void:
	if not board:
		push_error("Board node not found")
		return
	
	var current_game_board = BoardGenerator.generate_board(level)
	current_game_state = GameState.new(level, current_game_board, session_points)
	board.set_board(current_game_board)
	set_level_label(level)
	if total_points and level_points:
		total_points.set_score(current_game_state.session_points)
		level_points.set_score(current_game_state.current_points)
	targeted_card = null
	board.set_targeted_card(null)
	if end_screen:
		end_screen.visible = false
	if win_screen:
		win_screen.visible = false


# ============================================================================
# Event Handlers
# ============================================================================

func _on_card_clicked(card_position: CardLocation) -> void:
	if not current_game_state or not board:
		return
	if is_info_screen_visible:
		return
	if current_game_state.lost_game() or current_game_state.won_game():
		print("Game already lost or won")
		return
	if current_game_state.is_card_discovered(card_position):
		print("Card already discovered")
		return
	if targeted_card != null and targeted_card._is_equal(card_position):
		current_game_state.discover_card(card_position)
		board.set_card_discovered(card_position)
		board.set_targeted_card(null)
		play_box_break_sound()
		if total_points and level_points:
			total_points.set_score(current_game_state.session_points)
			level_points.set_score(current_game_state.current_points)
		if current_game_state.won_game():
			won_game(card_position)
		elif current_game_state.lost_game():
			lost_game(card_position)
	else:
		play_card_select()
		print("Targeting card: ", card_position.row, " col ", card_position.column)
		targeted_card = card_position
		board.set_targeted_card(card_position)

func _on_replay_clicked(_button: Node) -> void:
	start_new_game(Constants.STARTING_LEVEL, 0)

func _on_next_level_clicked(_button: Node) -> void:
	if not current_game_state:
		return
	start_new_game(min(current_game_state.current_level + 1, Constants.MAX_LEVEL), current_game_state.current_points + current_game_state.session_points)

func _on_mark_board_tapped(mark: int) -> void:
	if is_info_screen_visible:
		return
	if targeted_card != null:
		board.toggle_mark(targeted_card, mark)

func _on_sound_button_tapped(_button: Node) -> void:
	if is_info_screen_visible:
		return
	var new_enabled : bool = not sound_button.is_toggled()
	sound_button.set_toggled(new_enabled)
	sfx_enabled = new_enabled
	AudioManager.set_sfx_enabled(sfx_enabled)

func _on_music_button_tapped(_button: Node) -> void:
	if is_info_screen_visible:
		return
	var new_enabled : bool = not music_button.is_toggled()
	music_button.set_toggled(new_enabled)
	music_enabled = new_enabled
	AudioManager.set_music_enabled(music_enabled)
	if music_enabled:
		AudioManager.play_music("bg", "mp3")

func _on_info_button_tapped(_button: Node) -> void:
	if is_info_screen_visible:
		return
	info_screen.visible = true
	is_info_screen_visible = true
	

# ============================================================================
# Game Logic
# ============================================================================

func won_game(_card_position: CardLocation) -> void:
	AudioManager.play_music("win", "mp3")
	if win_screen:
		win_screen.visible = true

func lost_game(card_position: CardLocation) -> void:
	if music_enabled:
		AudioManager.play_music("lose", "mp3")
	if not current_game_state or not current_game_state.board or not board:
		return
	
	$Canvas/BoardShake.play("ShakeBoard")
	for zero in current_game_state.board.zeroes_locations:
		if current_game_state.is_card_discovered(zero):
			continue
		await get_tree().create_timer(Constants.CARD_REVEAL_DELAY).timeout
		board.set_card_discovered(zero)
		play_explosion_sound()
	await get_tree().create_timer(Constants.CARD_REVEAL_DELAY).timeout
	if end_screen:
		end_screen.visible = true


# ============================================================================
# UI Helpers
# ============================================================================

func set_level_label(level: int) -> void:
	if level_display:
		level_display.set_level(level)


# ============================================================================
# Audio
# ============================================================================

func play_card_select():
	AudioManager.play_sfx("card_select", "ogg")

func play_box_break_sound() -> void:
	AudioManager.play_sfx("card_reveal", "ogg")

func play_explosion_sound() -> void:
	AudioManager.play_sfx("explosion", "wav", -15.0)
	
func stop_music() -> void:
	AudioManager.stop_music()

func play_music() -> void:
	AudioManager.play_music("bg", "mp3")

func _on_info_screen_close_button_clicked(button: Variant) -> void:
	info_screen.visible = false
	is_info_screen_visible = false
