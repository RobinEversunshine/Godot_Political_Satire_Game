extends BaseGUIView

@onready var album_button_container = $AlbumsPage/ScrollContainer/VBoxContainer/CenterContainer/GridContainer
@onready var photos_page = $PhotosPage
@onready var photo_scroll = $PhotosPage/PhotoScroll

@onready var album_name_label = $PhotoSelectPage/header/CenterContainer/Label
@onready var inform = $PhotosPage/Inform
@onready var animation_player = $AnimationPlayer
@onready var password_page = $PasswordPage

var layer : int = 0
var inform_shown : bool = false
var active_album_button : Control


func _ready():
	clip_contents = true
	password_page.connect("right_password", password)
	
	for album_button in album_button_container.get_children():
		album_button.connect("album_pressed", album_button_pressed)


func album_button_pressed(album_button : Control):
	active_album_button = album_button
	if active_album_button.locked:
		password_page.open(active_album_button.password, active_album_button.password_hint)
		layer = 3
	else:
		into_album()


func password():
	into_album()
	active_album_button.locked = false
	Global.secret_album_lock = false
	#active_album_button.unlock()


func into_album():
	for child in photo_scroll.get_children():
		child.hide()
	active_album_button.photo_container.show()
	album_name_label.text = active_album_button.album_name
	photos_page.build_photos(active_album_button)
	animation_player.play("into_album")
	layer = 1
	active_album_button.unlock()


func back():
	if layer == 0:
		close_self()
	elif layer == 1:
		animation_player.play_backwards("into_album")
		layer = 0
	elif layer == 2:
		animation_player.play_backwards("into_photo")
		layer = 1
		if inform_shown:
			_on_inform_button_pressed()
	elif layer == 3:
		password_page.close()
		layer = 0


func _on_back_button_pressed():
	back()


func _on_inform_button_pressed():
	if !inform_shown:
		get_tree().create_tween().tween_property(inform, "position", Vector2(0, 340), 0.3).set_trans(Tween.TRANS_CUBIC)
		inform_shown = true
	else:
		get_tree().create_tween().tween_property(inform, "position", Vector2(0, 520), 0.3).set_trans(Tween.TRANS_CUBIC)
		inform_shown = false


