extends BaseGUIView

@onready var chatbox_container = $ChatList/ScrollContainer/MarginContainer/VBoxContainer
@onready var chat_page = $ChatPage
@onready var animation_player = $AnimationPlayer

var layer : int = 0


func _ready():
	clip_contents = true
	#PhoneText.skip_mode = false
	
	var chat_boxes : Array = chatbox_container.get_children()
	chat_boxes.sort_custom(compare_chatbox)
	for chat_box in chat_boxes:
		chatbox_container.move_child(chat_box, chat_boxes.find(chat_box))
		chat_box.connect("button_pressed", button_pressed)


func back():
	if layer == 0:
		close_self()
	elif layer == 1:
		animation_player.play_backwards("into_chat")
		layer = 0
		for child in chat_page.get_children():
			if child.available:
				child.set_able(false)


func button_pressed(contact : Contact):
	animation_player.play("into_chat")
	layer = 1
	for child in chat_page.get_children():
		if child.contact == contact:
			child.set_able(true)


func compare_chatbox(chat_box_a : Control, chat_box_b : Control):
	if chat_box_a.contact.unix_time > chat_box_b.contact.unix_time:
		return true
	else:
		return false


func close():
	#PhoneText.skip_mode = false
	await super.close()
	SoundPlayer.stop_sound(SoundPlayer.Textscroll)
