extends Node

# Central audio manager for SFX and music.
# Add this script as an Autoload singleton named "AudioManager" in the project settings.

var sfx_enabled: bool = true
var music_enabled: bool = true

var _fx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer


func _ready() -> void:
	# Create and configure internal audio players.
	_fx_player = AudioStreamPlayer.new()
	_fx_player.name = "FxPlayer"
	add_child(_fx_player)

	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.volume_db = -20.0
	_music_player.autoplay = false
	add_child(_music_player)


func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled
	# We don't stop currently playing SFX; they are short anyway.


func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if not music_enabled:
		stop_music()


func play_sfx(sound_name: String, extension: String = "ogg", volume_db: float = 0.0) -> void:
	if not sfx_enabled:
		return

	_fx_player.volume_db = volume_db
	var sound_path := "res://sounds/sfx/%s.%s" % [sound_name, extension]
	var stream: AudioStream = load(sound_path)

	if not stream:
		push_warning("AudioManager: Failed to load SFX: " + sound_path)
		return

	_fx_player.stop()
	_fx_player.stream = stream
	_fx_player.play()


func play_music(sound_name: String, extension: String = "mp3") -> void:
	if not music_enabled:
		return

	var sound_path := "res://sounds/music/%s.%s" % [sound_name, extension]
	var stream: AudioStream = load(sound_path)

	if not stream:
		push_warning("AudioManager: Failed to load music: " + sound_path)
		return

	_music_player.stop()
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	if _music_player:
		_music_player.stop()

