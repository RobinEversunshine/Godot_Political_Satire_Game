extends Control

@onready var animation_player = $AnimationPlayer
@onready var texture_rect = $TextContainer/TextureRect
@onready var texture_rect_2 = $TextContainer/TextureRect2


func _ready():
	animation_player.play("click")
	await animation_player.animation_finished
	queue_free()

func set_true_false(true_false : bool):
	if true_false:
		texture_rect_2.hide()
	else:
		texture_rect.hide()

func update_tf(mission_name : String):
	position = get_local_mouse_position() - Vector2(16, 24)
	if Global.mission_complete(mission_name):
		set_true_false(true)
	else:
		set_true_false(false)
