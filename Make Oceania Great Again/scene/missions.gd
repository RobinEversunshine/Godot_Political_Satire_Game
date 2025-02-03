extends BaseGUIView


@onready var mission_box_container = $ScrollContainer/MarginContainer/VBoxContainer
@onready var animation_player = $AnimationPlayer



func open():
	animation_player.play("open")
	Game.get_up_scroll().noti_anim_end()


func close():
	animation_player.play_backwards("open")
	await animation_player.animation_finished

