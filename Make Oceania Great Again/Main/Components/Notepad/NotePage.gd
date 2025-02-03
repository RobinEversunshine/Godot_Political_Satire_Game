extends Control

@onready var note_name = $header/CenterContainer/NoteName
@onready var note_content = $Content/ScrollContainer/MarginContainer/NoteContent
@onready var scroll_container = $Content/ScrollContainer


func _ready():
	scroll_container.get_v_scroll_bar().use_parent_material = true


func update_content(note_box : Control):
	scroll_container.scroll_vertical = 0
	note_name.text = note_box.note_name
	note_content.text = ""
	#if note_box.text_name != "":
		#var path : String = "res://Assets/Dialogues/Notes/" + note_box.text_name + ".txt"
		#if FileAccess.file_exists(path):
			#note_content.text = FileAccess.get_file_as_string(path)
		#
	for child in note_box.get_children():
		if child is Label:
			note_content.text = child.text
			#print("8964".to_utf8_buffer().hex_encode())
			#print("38393634".hex_decode().get_string_from_utf8())
			break
		
