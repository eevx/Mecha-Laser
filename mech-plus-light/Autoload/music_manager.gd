extends AudioStreamPlayer

@export var _theme_dictionary : Dictionary[String, AudioStream]

var _set_volume := 0.

func play_theme(theme_name : String = "theme1", volume := 0.):
	if _theme_dictionary.has(theme_name):
		switch_track(_theme_dictionary[theme_name], volume)
		_set_volume = volume
		
func pause_theme(pause_volume := -20.):
	var tween = create_tween()
	tween.tween_property(self, "volume_db", pause_volume, 1.).set_ease(Tween.EASE_IN)

func resume_theme():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", _set_volume, 1.).set_ease(Tween.EASE_IN)

func switch_track(track : AudioStream, volume := 0.):
	if stream == track:
		return
	stream = track
	volume_db = volume
	set_playing(true)
