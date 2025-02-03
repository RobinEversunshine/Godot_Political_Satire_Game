extends BaseGUIView

@onready var color_setting_page = $ColorSettingPage
@onready var popup = $Popup
@onready var animation_player = $AnimationPlayer

var layer : int = 0
var button_list : Array = [reset, return_to_title, quit]

func _ready():
	clip_contents = true


func back():
	if layer == 0:
		close_self()
	elif layer == 1:
		animation_player.play_backwards("into_color")
		layer = 0
	elif layer == 2:
		popup.close()
		layer = 0


func into_color():
	animation_player.play("into_color")
	layer = 1


func popup_disconnect():
	for button_name in button_list:
		if popup.is_connected("accept_pressed", button_name):
			popup.disconnect("accept_pressed", button_name)


func popup_connect(button_name : Callable):
	popup.open()
	layer = 2
	popup_disconnect()
	popup.connect("accept_pressed", button_name)


#game methods
func reset():
	Game.reset()

func return_to_title():
	Game.reset(false)

func quit():
	await LevelTransition.fade_in()
	get_tree().quit()


#color buttons
func _on_forward_button_pressed():
	Game.get_color().change_gradient("forward")


func _on_backward_button_pressed():
	Game.get_color().change_gradient("backward")


func _on_white_color_button_pressed():
	color_setting_page.update_mode("White Color")
	into_color()


func _on_black_color_button_pressed():
	color_setting_page.update_mode("Black Color")
	into_color()


func _on_random_color_button_pressed():
	Game.get_color().random_color()


#game buttons
func _on_reset_button_pressed():
	popup_connect(reset)


func _on_return_button_pressed():
	popup_connect(return_to_title)


func _on_quit_button_pressed():
	popup_connect(quit)


func _on_back_button_pressed():
	back()



