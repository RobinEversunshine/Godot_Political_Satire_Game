extends Node

#560, 315
#4480, 2520
#336, 189
#2688, 1512
const save_path = "res://savegame.bin"
var edit_mode : bool = false
var playthrough_count : int = 0
var reset_enable : bool = false

#1680, 945
#700, 945

func _ready():
	#get_window().size = Vector2i(1680, 945)
	
	if get_game_root():
		#await get_tree().create_timer(3).timeout
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		#Game.get_color().gradient_index = 3
		await get_tree().process_frame
		Game.get_color().random_color([0,3,5,9])
		
		if OS.get_locale_language() == "zh":
			TranslationServer.set_locale("zh")
		else:
			TranslationServer.set_locale("en")
		
		var window = get_window()
		window.title = "MAKE OCEANIA GREAT AGAIN!!!!"
		if window.mode == 0:
			get_tree().create_tween().tween_property(window, "position", window.position - Vector2i(490, 0), 2).set_trans(Tween.TRANS_CUBIC)
			get_tree().create_tween().tween_property(window, "size", Vector2i(1680, 945), 2).set_trans(Tween.TRANS_CUBIC)
		
		await get_tree().process_frame
		SoundPlayer.play_sound(SoundPlayer.Horror)


func get_game_root() -> Node:
	return get_node("/root/GameScene")


func get_gui_view_manager() -> GUIViewManager:
	return get_game_root().get_node("%GUIViewManager")

func get_contact_list():
	return get_game_root().get_node("%ContactList")

func get_up_scroll():
	return get_game_root().get_node("%UpScroll")

func new_noti(app_jump : String, inform1 : String = "", inform2 : String = ""):
	get_up_scroll().new_notification(app_jump, inform1, inform2)



func get_color():
	return get_game_root().get_node("%ColorGradientList")


func get_phone():
	return get_game_root().get_node("%Phone")

func phone_shake(shake_amount : float = 10, shake_time : float = 0):
	get_phone().camera_shake(shake_amount, shake_time)

func phone_stop_shake():
	get_phone().stop_shake()

func get_camera():
	return get_game_root().get_node("%Camera2D")

func camera_shake(shake_amount : float = 60):
	get_camera().camera_shake(shake_amount)


func reset(reset_directly : bool = true):
	playthrough_count += 1
	save_game()
	reset_enable = reset_directly
	get_contact_list().reset_history_call()
	get_gui_view_manager().reset_noti()
	Global.reset_script()
	PhoneText.reset_script()
	DateTime.reset_time()
	await LevelTransition.fade_in()
	SoundPlayer.stop_all_sound(SoundPlayer.Horror)
	get_color().random_color()
	get_tree().reload_current_scene()


func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var data: Dictionary = {
		"player_hp": "Game.player_hp",
		"gold": "Game.gold",
	}
	var jstr = JSON.stringify(data)
	file.store_line(jstr)


func load_game():
	var file = FileAccess.open(save_path, FileAccess.READ)
	if FileAccess.file_exists(save_path):
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				Game.player_hp = current_line["player_hp"]
				Game.gold = current_line["gold"]


func save_exists():
	return FileAccess.file_exists(save_path)


#func save():
	#var packed_scene = PackedScene.new()
	#packed_scene.pack(get_tree().current_scene)
	#ResourceSaver.save(packed_scene, "res://Saves/save.tscn")
var shader_gradient = preload("res://Assets/Resource/ColorGradients/shader_gradient.tres")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		edit_mode = !edit_mode
	
	if event.is_action_pressed("language"):
		if TranslationServer.get_locale() == "en":
			TranslationServer.set_locale("zh")
		else:
			TranslationServer.set_locale("en")
	
	if event.is_action_pressed("transparent"):
		shader_gradient.colors[0] = Color(Color.BLACK, 0.3)
		shader_gradient.colors[-1] = Color(Color.WHITE, 0.5)
		
		
		
		









