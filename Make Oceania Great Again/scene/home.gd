extends BaseGUIView

@onready var scroll_container = $ScrollContainer
@onready var h_box_container = scroll_container.get_child(0)
@onready var page_points = $PagePoints

var page_current_index : int = 0
var page_pos_x : Array = []

var is_clicking : bool = false
var click_time : float
const click_time_threshold : float = 0.2
var click_pos_start : Vector2


func _ready():
	await get_tree().process_frame
	var page_nodes : Array = h_box_container.get_children()
	for page in page_nodes:
		if "Page" in page.name:
			page_pos_x.append(page.position.x)


func _process(delta):
	if is_clicking:
		click_time += delta


func set_page_pos():
	page_current_index = clamp(page_current_index, 0, page_pos_x.size() - 1)
	page_points.set_current_page(page_current_index)
	var target_pos = page_pos_x[page_current_index]
	get_tree().create_tween().tween_property(scroll_container, "scroll_horizontal", target_pos, 0.3).set_trans(Tween.TRANS_CUBIC)
	
	if page_current_index == 3:
		SoundPlayer.play_sound(SoundPlayer.Glitch)
	else:
		SoundPlayer.stop_sound(SoundPlayer.Glitch)


func _on_scroll_container_gui_input(event):
	if event is InputEventMouseButton && Game.get_gui_view_manager().active_view_path.size() == 1:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				click_pos_start = get_local_mouse_position()
				is_clicking = true

			else:
				is_clicking = false
				if click_time > click_time_threshold:

					var nearest_length : float = 10000
					var nearest_pos : float
					
					for pos in page_pos_x:
						var diff = abs(scroll_container.scroll_horizontal - pos)
						if diff < nearest_length:
							nearest_length = diff
							nearest_pos = pos

					page_current_index = page_pos_x.find(nearest_pos)

				else:
					var relative = get_local_mouse_position() - click_pos_start
					
					if abs(relative.x) > 20 && relative.x != 0:
						var dir : int
						if relative.x > 0:
							dir = -1
						elif relative.x < 0:
							dir = 1
						page_current_index += dir
				
				set_page_pos()
				click_time = 0
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP && event.pressed == true:
			page_current_index -= 1
			set_page_pos()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN && event.pressed == true:
			page_current_index += 1
			set_page_pos()


func open():
	pass

func close():
	pass

