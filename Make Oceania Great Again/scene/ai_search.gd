extends BaseGUIView

@onready var text_edit = $VBoxContainer/TextEdit
@onready var search_item_list = $VBoxContainer/SearchSelectPopup/SearchItemList
@onready var search_button = $VBoxContainer/TextEdit/SearchButton

@onready var scroll_container = $ScrollContainer
@onready var margin_container = scroll_container.get_child(0)
@onready var v_box_container = margin_container.get_child(0)

@onready var animation_player = $AnimationPlayer

@export var ai_message : PackedScene


const dialogue_resource = preload("res://Assets/Dialogues/ai_search.dialogue")

var trans_dict : Dictionary

var dialogue_line : DialogueLine:
	set(next_dialogue_line):
		#dialogue ends
		if not next_dialogue_line:
			search_button.disabled = false
			search_button.modulate.a = 1
			return
		
		dialogue_line = next_dialogue_line
		
		await add_new_message(dialogue_line)
		await get_tree().create_timer(1).timeout
		next(dialogue_line.next_id)


func _ready():
	#TranslationServer.set_locale("zh")
	%SearchSelectPopup.visible = false
	text_edit.get_v_scroll_bar().modulate.a = 0
	text_edit.get_h_scroll_bar().modulate.a = 0
	text_edit.get_v_scroll_bar().mouse_filter = 2
	text_edit.get_h_scroll_bar().mouse_filter = 2
	search_item_list.clear()
	
	var title_list : Array
	for title in dialogue_resource.titles:
		if title != "other":
			if !title.begins_with("hide"):
				title_list.append(title)
				trans_dict[tr(title)] = title
			else:
				trans_dict[tr(title.right(-5))] = title.right(-5)
	
	title_list.sort_custom(sort)
	
	for title in title_list:
		search_item_list.add_item(tr(title))


func sort(a, b):
	if int(dialogue_resource.titles[a]) < int(dialogue_resource.titles[b]):
		return true
	return false


func add_new_message(input_dialogue_line : DialogueLine, is_title : bool = false):
	if not input_dialogue_line.text.is_empty():
		var new_message = ai_message.instantiate()
		v_box_container.add_child(new_message)
		new_message.modulate = Color.TRANSPARENT
		
		var new_dialogue_label = new_message.dialogue_label
		new_dialogue_label.dialogue_line = input_dialogue_line
		
		#mission complete
		var mission_name : String = input_dialogue_line.get_tag_value("mission")
		if mission_name != "":
			new_message.update_mission(mission_name)
		
		await get_tree().process_frame
		new_dialogue_label.connect("line_count_changed", update_scroll)
		update_scroll()
		
		
		#dialogue type out
		if is_title:
			new_message.is_title()
			create_tween().tween_property(new_message, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_CUBIC)
		else:
			create_tween().tween_property(new_message, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_CUBIC)
			new_dialogue_label.type_out()
			#SoundPlayer.play_sound(SoundPlayer.Textscroll)
			await new_dialogue_label.finished_typing
			#SoundPlayer.stop_sound(SoundPlayer.Textscroll)
		
	else:
		return


func update_scroll(scroll_time : float = 0.2):
	await get_tree().process_frame
	var scroll_max = margin_container.size.y - scroll_container.size.y
	get_tree().create_tween().tween_property(scroll_container, "scroll_vertical", scroll_max, scroll_time).set_trans(Tween.TRANS_CUBIC)


func start(title : String) -> void:
	var title_dialogue_line = DialogueLine.new()
	title_dialogue_line.text = tr(title)
	await add_new_message(title_dialogue_line, true)
	await get_tree().create_timer(2).timeout
	if "hide_" + title in dialogue_resource.titles:
		title = "hide_" + title
	elif !title in dialogue_resource.titles:
		title = "other"
	self.dialogue_line = await dialogue_resource.get_next_dialogue_line(title)


func next(next_id: String) -> void:
	self.dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id)


func alert():
	await get_tree().create_timer(1).timeout
	close_self()
	has_method("alert")



func _on_month_item_list_item_selected(index):
	text_edit.text = search_item_list.get_item_text(index)
	%SearchSelectPopup.visible = false


func _on_search_button_pressed():
	if !text_edit.text.is_empty():
		%SearchSelectPopup.visible = false
		search_button.disabled = true
		search_button.modulate.a = 0.5
		
		var title = text_edit.text
		if title in trans_dict:
			title = trans_dict[title]
		
		if animation_player.current_animation_position < 1:
			animation_player.play("search")
			await animation_player.animation_finished
		
		await get_tree().create_timer(0.5).timeout
		start(title)


func _on_text_edit_gui_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			%SearchSelectPopup.visible = !%SearchSelectPopup.visible


func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			%SearchSelectPopup.visible = false


func _on_scroll_container_gui_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			%SearchSelectPopup.visible = false


