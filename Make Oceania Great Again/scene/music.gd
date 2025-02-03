extends BaseGUIView

@onready var cd_texture = $CD/SubViewport/TextureRect/CDTexture
@onready var cd_texture2 = $CD2/SubViewport/TextureRect/CDTexture

@onready var pause_button = $CenterContainer4/HBoxContainer/PauseButton
@onready var backward_button = $CenterContainer4/HBoxContainer/BackwardButton
@onready var forward_button = $CenterContainer4/HBoxContainer/ForwardButton

@onready var song_name = $CenterContainer3/SongName
@onready var h_slider = $CenterContainer2/HBoxContainer/HSlider
@onready var current_time = $CenterContainer2/HBoxContainer/CurrentTime
@onready var all_time = $CenterContainer2/HBoxContainer/AllTime

@onready var animation_player = $AnimationPlayer
@onready var glitch_effect = $GlitchEffect

var allow_close : bool = true
var slider_is_dragging : bool = false
var length : float

func _ready():
	clip_contents = true
	SoundPlayer.connect("song_changed", update_song)
	SoundPlayer.connect("song_paused", song_paused)
	SoundPlayer.song_stream.connect("finished", change_music)
	update_song()
	cd_texture.texture = SoundPlayer.current_playing.cd_texture
	if !SoundPlayer.music_playing:
		pause_button.button_pressed = true
		cd_texture.rotation = SoundPlayer.rotation
		update_current_time(SoundPlayer.get_current_pos())


func _process(delta):
	if SoundPlayer.music_playing:
		cd_texture.rotation = SoundPlayer.rotation
		cd_texture2.rotation = SoundPlayer.rotation
		if !slider_is_dragging:
			update_current_time(SoundPlayer.get_current_pos())


func update_current_time(current_pos : float):
	var second = DateTime.add_zero(int(current_pos) % 60)
	var minute = DateTime.add_zero(floor(current_pos / 60))
	current_time.text = minute + ":" + second
	h_slider.value = current_pos / length


func update_song():
	length = SoundPlayer.current_playing.audio_source.get_length()
	var second = DateTime.add_zero(int(length) % 60)
	var minute = DateTime.add_zero(floor(length / 60))
	all_time.text = minute + ":" + second
	
	song_name.text = SoundPlayer.current_playing.display_name
	pause_button.button_pressed = false


func song_paused():
	create_tween().tween_property(cd_texture, "rotation", cd_texture.rotation + 0.01, 0.2).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property(cd_texture2, "rotation", cd_texture2.rotation + 0.01, 0.2).set_trans(Tween.TRANS_CUBIC)


func change_music(option : String = "forward", instant : bool = false):
	if option == "forward":
		cd_texture.texture = SoundPlayer.current_playing.cd_texture
		if !instant:
			animation_player.play("forward")
		else:
			animation_player.play("backward")
			animation_player.stop()
			
	elif option == "backward":
		cd_texture2.texture = SoundPlayer.current_playing.cd_texture
		if !instant:
			animation_player.play("backward")
		else:
			animation_player.play("forward")
			animation_player.stop()
	
	SoundPlayer.change_music(option, instant)
	
	if !instant:
		backward_button.disabled = true
		forward_button.disabled = true
		h_slider.editable = false
		await get_tree().create_timer(0.5).timeout
	
	if option == "forward":
		cd_texture2.rotation = 0
		cd_texture2.texture = SoundPlayer.current_playing.cd_texture
	elif option == "backward":
		cd_texture.rotation = 0
		cd_texture.texture = SoundPlayer.current_playing.cd_texture
	
	if !instant:
		await animation_player.animation_finished
		backward_button.disabled = false
		forward_button.disabled = false
		h_slider.editable = true


func _on_pause_button_toggled(toggled_on):
	if toggled_on:
		allow_close = false
		SoundPlayer.pause_music()
		
		#await get_tree().create_timer(0.5).timeout
		#glitch_effect.show()
		#SoundPlayer.play_sound(SoundPlayer.Glitch)
		#
		#await get_tree().create_timer(0.5).timeout
		#pause_button.button_pressed = false
		#SoundPlayer.continue_music(0)
		#
		#glitch_effect.hide()
		#SoundPlayer.stop_sound(SoundPlayer.Glitch)
		allow_close = true
	else:
		SoundPlayer.continue_music()


func _on_h_slider_drag_started():
	slider_is_dragging = true


func _on_h_slider_drag_ended(value_changed):
	if !SoundPlayer.music_playing:
		await pause_button.pressed
	var current_value : float = h_slider.value
	if current_value == 1:
		current_value = 0.99
	SoundPlayer.song_stream.seek(length * current_value)
	slider_is_dragging = false


func _on_forward_button_pressed():
	allow_close = false
	change_music("forward")
	
	#await get_tree().create_timer(3).timeout
	#glitch_effect.show()
	#SoundPlayer.play_sound(SoundPlayer.Glitch)
	#
	#await get_tree().create_timer(0.5).timeout
	#change_music("backward", true)
	#
	#glitch_effect.hide()
	#SoundPlayer.stop_sound(SoundPlayer.Glitch)
	allow_close = true


func _on_backward_button_pressed():
	allow_close = false
	change_music("backward")
	
	#await get_tree().create_timer(3).timeout
	#glitch_effect.show()
	#SoundPlayer.play_sound(SoundPlayer.Glitch)
	#
	#await get_tree().create_timer(0.5).timeout
	#change_music("forward", true)
	#
	#glitch_effect.hide()
	#SoundPlayer.stop_sound(SoundPlayer.Glitch)
	allow_close = true


func close_self():
	if allow_close:
		super.close_self()





