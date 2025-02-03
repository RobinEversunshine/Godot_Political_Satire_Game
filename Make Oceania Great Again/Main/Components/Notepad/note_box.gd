extends Control

@onready var note_name_label = $MarginContainer/HBoxContainer/VBoxContainer/NoteName
@onready var note_hint_label = $MarginContainer/HBoxContainer/VBoxContainer/NoteHint
@onready var note_button = $NoteButton
@onready var lock_texture = $MarginContainer/LockTexture


@export var note_name : String
@export var note_hint : String
#@export var text_name : String

@export var disabled : bool = false
@export var hide_title : bool = false
@export var locked : bool = false:
	set(value):
		locked = value
		if !value:
			if note_name in Global.Note:
				Global.Note[note_name] = true
			update_lock()

@export var password : String


signal note_pressed

func _ready():
	note_name_label.text = note_name
	if note_hint != "":
		note_hint_label.text = note_hint
	else:
		note_hint_label.hide()
	
	if note_name in Global.Note && Global.Note[note_name]:
		locked = false
		disabled = false
	
	update_lock()
	update_disable()


func update_lock():
	if !locked:
		lock_texture.hide()


func update_disable():
	if disabled:
		modulate.a = 0.5
		note_button.disabled = true
		if hide_title:
			note_name_label.text = "???"
	else:
		modulate.a = 1
		note_button.disabled = false
		note_name_label.text = note_name


func _on_note_button_pressed():
	emit_signal("note_pressed", self)


func _on_note_button_mouse_entered():
	if !disabled:
		modulate.a = 0.7


func _on_note_button_mouse_exited():
	if !disabled:
		modulate.a = 1
