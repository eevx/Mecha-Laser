extends Control

const CONFIG_PATH := "user://audio.cfg"

# Bus names
const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

const MUTE_DB := -80.0
const MIN_DB := -80.0
const MAX_DB := 0.0

@onready var master_slider: HSlider = $bar_container/Master
@onready var music_slider: HSlider = $bar_container/Music
@onready var sfx_slider: HSlider = $bar_container/SFX

func _ready() -> void:
	_load_settings()

func _on_master_changed(value: float) -> void:
	_set_bus_volume_db(BUS_MASTER, _slider_to_db(value))
	_save_setting("master", int(value))


func _on_music_changed(value: float) -> void:
	_set_bus_volume_db(BUS_MUSIC, _slider_to_db(value))
	_save_setting("music", int(value))


func _on_sfx_changed(value: float) -> void:
	_set_bus_volume_db(BUS_SFX, _slider_to_db(value))
	_save_setting("sfx", int(value))



# Convert slider 0 - 100 to dB. 0 -> MUTE_DB, 100 -> 0 dB.
func _slider_to_db(slider_value: float) -> float:
	if int(slider_value) <= 0:
		return MUTE_DB
	var t := slider_value / 100.0
	return lerp(MIN_DB, MAX_DB, t)


# Apply dB to bus by name
func _set_bus_volume_db(bus_name: String, db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_warning("Audio bus '%s' not found." % bus_name)
		return
	AudioServer.set_bus_volume_db(idx, db)


func _save_setting(key: String, value: int) -> void:
	var cfg := ConfigFile.new()
	var _err := cfg.load(CONFIG_PATH)
	cfg.set_value("audio", key, value)
	cfg.save(CONFIG_PATH)

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	var _err := cfg.load(CONFIG_PATH)
	var master_val := 100
	var music_val := 100
	var sfx_val := 100
	if _err == OK:
		master_val = int(cfg.get_value("audio", "master", master_val))
		music_val = int(cfg.get_value("audio", "music", music_val))
		sfx_val = int(cfg.get_value("audio", "sfx", sfx_val))

	master_slider.value = master_val
	music_slider.value = music_val
	sfx_slider.value = sfx_val
