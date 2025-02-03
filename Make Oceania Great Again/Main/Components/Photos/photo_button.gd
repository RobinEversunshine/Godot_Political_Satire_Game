extends Control

@onready var texture_rect = $TextureRect
@onready var photo_button = $CanvasGroup/PhotoButton

const BROKEN_304 = preload("res://Assets/Textures/photos/broken_304.png")

signal into_photo


func update_texture(texture : Texture2D, hide_photo : bool = false):
	if texture != BROKEN_304:
		photo_button.texture_normal = texture
		texture_rect.hide()
	if hide_photo:
		hide()


func _on_photo_button_pressed():
	var index : int = get_parent().get_children().find(self)
	emit_signal("into_photo", index)


func _on_photo_button_mouse_entered():
	modulate.a = 0.9


func _on_photo_button_mouse_exited():
	modulate.a = 1
