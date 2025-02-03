extends BaseGUIView

@onready var scroll_container = $NoteList/ScrollContainer
@onready var button_list_container = $NoteList/ButtonList/HBoxContainer
@onready var note_page = $NotePage
@onready var password_page = $PasswordPage

@onready var animation_player = $AnimationPlayer
@onready var note_color = $NoteList/ScrollContainer/HBoxContainer/ScrollContainer2/MarginContainer/VBoxContainer/Note_color

var layer : int = 0
var active_note_box : Control
var button_list : Array 


func _ready():
	clip_contents = true
	password_page.connect("right_password", password)
	
	button_list = button_list_container.get_children()
	for button in button_list:
		button.connect("pressed", switch_note_list)
	
	var NoteList : Array = []
	for note_container in scroll_container.get_child(0).get_children():
		var note_list = note_container.get_child(0).get_child(0).get_children()
		NoteList.append_array(note_list)
	
	for note_box in NoteList:
		note_box.connect("note_pressed", note_pressed)
		
	await get_tree().process_frame
	if !Global.Note["Note_color"]:
		right_color()


func back():
	if layer == 0:
		close_self()
	elif layer == 1:
		animation_player.play_backwards("into_note")
		layer = 0
	elif layer == 2:
		password_page.close()
		layer = 0


func note_pressed(note_box : Control):
	active_note_box = note_box
	if active_note_box.locked:
		password_page.open(active_note_box.password)
		layer = 2
	else:
		into_note()


func password():
	into_note()
	active_note_box.locked = false


func into_note():
	animation_player.play("into_note")
	layer = 1
	note_page.update_content(active_note_box)


func switch_note_list():
	var cur_button = get_viewport().gui_get_focus_owner()
	if cur_button in button_list:
		for button in button_list:
			button.disabled = false
		cur_button.disabled = true
		
		var i : int = button_list.find(cur_button)
		get_tree().create_tween().tween_property(scroll_container, "scroll_horizontal", i * 304, 0.4).set_trans(Tween.TRANS_CUBIC)


func _on_back_button_pressed():
	back()


func right_color():
	var shader_gradient = material.get_shader_parameter("Gradient").gradient.colors
	var color1 = shader_gradient[-1]
	var color2 = shader_gradient[0]
	if color1.h > 0.16 && color1.h < 0.4 && color2.h > 0.16 && color2.h < 0.4:
		Game.new_noti("Notepad", "Note_color")
		Global.Note["Note_color"] = true
		note_color.disabled = false
		note_color.update_disable()
		await get_tree().create_timer(2).timeout
		Game.get_color().add_gradient()
		Game.new_noti("Settings", "Settings", "Theme Gameboy has been added to your color themes")

