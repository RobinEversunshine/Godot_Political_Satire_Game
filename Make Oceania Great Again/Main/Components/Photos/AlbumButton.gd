extends Control

@export var album_texture : Texture2D
@export var album_name : String
@export var locked : bool = false
@export var password : String
@export var password_hint : String
@export var photo_container : HBoxContainer
@export var first_click_method : String
@export var unlocked_method : String

@onready var album_button = $VBoxContainer/Panel/AlbumButton
@onready var texture_rect = $VBoxContainer/Panel/AlbumButton/SubViewport/TextureRect

@onready var label = $VBoxContainer/Label


signal album_pressed

func _ready():
	if album_texture != null:
		texture_rect.stretch_mode = 6
		texture_rect.texture = album_texture
	label.text = album_name
	update_lock()


func update_lock():
	if locked:
		if !Global.secret_album_lock:
			locked = false


func unlock():
	if Global.has_method(unlocked_method):
		Global.call(unlocked_method)


func _on_album_button_pressed():
	emit_signal("album_pressed", self)
	if Global.has_method(first_click_method):
		Global.call(first_click_method)


func _on_album_button_mouse_entered():
	modulate.v = 0.7


func _on_album_button_mouse_exited():
	modulate.v = 1
