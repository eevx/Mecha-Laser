extends Node

@export var sfx: Dictionary[String, AudioStream]
@export var random_sound_array: Array[AudioStream] = []
var active_players: Array[AudioStreamPlayer] = []

func play_sfx(sfx_name: String, volume_db: float = 0.0, randomised_pitch: bool = false, pitch:=randf_range(0.8,1.2) , playback_start: float = 0.0, playback_end:= sfx[sfx_name].get_length()) -> void:
	if not sfx.has(sfx_name):
		push_warning("SFXManager: Sound not found - " + sfx_name)
		return

	var stream: AudioStream = sfx[sfx_name]
	if stream == null:
		push_warning("SFXManager: Null stream for name - " + sfx_name)
		return

	_play_stream(stream, volume_db, randomised_pitch, pitch, playback_start, playback_end)

##TO PLAY a random sfx from a given array of stream in the sfx manaager.
func random_sound(randomised_pitch: bool = false, volume_db: float = 0.0, pitch := randf_range(0.5,1.5)) -> void:
	if random_sound_array.is_empty():
		push_warning("SFXManager: 'random_sound_array' array is empty!")
		return

	var stream: AudioStream = random_sound_array.pick_random()
	if stream == null:
		push_warning("SFXManager: Null stream in 'random_sound_array'!")
		return

	_play_stream(stream, volume_db, randomised_pitch, pitch)

##DO NOT ACCESS THE SFX MANAGER USING THIS.Use Commands : SfxManager.playsfx( args[]...)
func _play_stream(stream: AudioStream, volume_db: float, randomised_pitch: bool, pitch:=randf_range(0.8,1.2), playback_start: float = 0.0, playback_end := stream.get_length()) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch if randomised_pitch else 1.0

	add_child(player)
	player.play(playback_start)
	if playback_end > 0.0:
		var duration = playback_end - playback_start
		if duration > 0.0:
			await get_tree().create_timer(duration).timeout
			if is_instance_valid(player):
				player.stop()

	player.finished.connect(func():
		active_players.erase(player)
		player.queue_free()
	)
	active_players.append(player)
