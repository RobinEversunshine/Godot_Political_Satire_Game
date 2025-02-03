extends Control


@onready var state = $CenterContainer/PopupPanel/State
@onready var animation_player = $AnimationPlayer

signal accept_pressed


func _ready():
	clip_contents = true
	hide()


func open():
	animation_player.play("open")
	state.text = "Are you sure?"


func close():
	animation_player.play_backwards("open")
	#await animation_player.animation_finished


func _on_accept_button_pressed():
	emit_signal("accept_pressed")


func _on_cancel_button_pressed():
	close()

