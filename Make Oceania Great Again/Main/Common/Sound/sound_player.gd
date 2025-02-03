extends Node

var Ringing : AudioStream = load("res://Assets/Sound/SFX/ringing.wav")
var Doorbell : AudioStream = load("res://Assets/Sound/SFX/415763__thebuilder15__doorbell-notification.wav")
var Vibrating : AudioStream = load("res://Assets/Sound/SFX/466217__harrisando__vibrating_1.wav")
var Phoneout : AudioStream = load("res://Assets/Sound/SFX/453261__lyd4tuna__call-going-to-voicemail_1.wav")
var Phoneoff : AudioStream = load("res://Assets/Sound/SFX/150136__gregsmedia__phone-off-the-hook_1.wav")
var Glitch : AudioStream = load("res://Assets/Sound/SFX/209295__tmc_zach__vtech-alphabet-glitch-noise-03.wav")

var Chicken : AudioStream = load("res://Assets/Sound/SFX/170806__esperar__angry-chicken-imitations.wav")
var Textscroll : AudioStream = load("res://Assets/Sound/SFX/524478__evretro__text-scroll-a5-200-openmpt-echo-pan.wav")
var Office : AudioStream = load("res://Assets/Sound/SFX/office_ambient.wav")
var Horror : AudioStream = load("res://Assets/Sound/SFX/540634__zhr__horror-ambient.mp3")
var Walking : AudioStream = load("res://Assets/Sound/SFX/395561__soundsforhim__walking-in-a-forest-quickly.wav")
var FBI : AudioStream = load("res://Assets/Sound/SFX/656732__paladinvii__fbi-open-up-pvii.mp3")

#@export var audio_random : AudioStreamRandomizer
@export var songs_list : Array[Song]

@onready var audio_players = $AudioPlayers
@onready var song_stream = $SongPlayer

var songsMap : Dictionary = {}

var music_playing : bool = false:
	set(value):
		if music_playing == true && value == false:
			create_tween().tween_property(self, "rotation", rotation + 0.01, 0.2).set_trans(Tween.TRANS_CUBIC)
			emit_signal("song_paused")
		music_playing = value

var rotation : float = 0
const speed : float = 0.1

var current_playing : Song

signal song_changed
signal song_paused


func _ready():
	_build_songs_map()
	#play_music("air")
	current_playing = songsMap["air"]


#using for cd rotation in music app
func _process(delta):
	if music_playing:
		rotation += delta * speed


func get_current_pos():
	return song_stream.get_playback_position()


#input song's id to find the song
func _build_songs_map():
	for song_container in songs_list:
		if song_container == null:
			continue
		songsMap[song_container.id] = song_container


#SFX methods
func play_sound(sound : AudioStream):
	for audio_stream in audio_players.get_children():
		if !audio_stream.playing:
			audio_stream.stream = sound
			audio_stream.play()
			break

func stop_sound(sound : AudioStream):
	for audio_stream in audio_players.get_children():
		if audio_stream.stream == sound:
			audio_stream.stop()


func stop_all_sound(exception : AudioStream = null):
	for audio_stream in audio_players.get_children():
		if audio_stream.playing && audio_stream != exception:
			audio_stream.stop()


#I used to assign a song to each level in Path of Pain, used when song changes in next level
func play_music(music_id : String):
	music_playing = true
	var music : Song = songsMap[music_id]
	current_playing = music
	if song_stream.stream != music.audio_source:
		await set_music_volume(-20)
		song_stream.stream = music.audio_source
		song_stream.play()
		set_music_volume(0)
	else:
		song_stream.play()
		set_music_volume(0)


#in music app, switch to last/next music when pressing button or current music ends
func change_music(option : String = "forward", instant : bool = false):
	var id_in_list : int = songs_list.find(current_playing)
	if option == "forward":
		if id_in_list == songs_list.size() - 1:
			id_in_list = 0
		else:
			id_in_list += 1
	elif option == "backward":
		if id_in_list == 0:
			id_in_list = songs_list.size() - 1
		else:
			id_in_list -= 1
	var next_song : Song = songs_list[id_in_list]
	if !instant:
		music_playing = false
	current_playing = next_song
	if !instant:
		await set_music_volume(-20)
	else:
		set_music_volume(-20, 0)
	
	rotation = 0
	song_stream.stream = next_song.audio_source
	song_stream.play()
	emit_signal("song_changed")
	set_music_volume(0)
	
	if !instant:
		await get_tree().create_timer(0.4).timeout
		music_playing = true


func stop_music():
	music_playing = false
	await set_music_volume(-20)
	song_stream.stop()


func set_music_volume(volume : float, tween_time : float = 1):
	await create_tween().tween_property(song_stream, "volume_db", volume, tween_time).finished


#used when hitting pause button in music app, or when someone calls in
func pause_music():
	music_playing = false
	await set_music_volume(-20)
	if !music_playing:
		song_stream.stream_paused = true


func continue_music(tween_time : float = 1):
	music_playing = true
	set_music_volume(0, tween_time)
	song_stream.stream_paused = false


func _on_song_player_finished():
	if !Game.get_gui_view_manager().find_view("Music"):
		change_music()


