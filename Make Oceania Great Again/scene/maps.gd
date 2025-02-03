extends BaseGUIView

@export var graph_edit : GraphEdit
@export var map : Node2D
@export var map_texture : Node2D
@onready var map_size = $MapInterface/Buttons/BackBufferCopy/MapSize
@onready var map_interface = $MapInterface

var is_dragging : bool = false
var drag_offset : Vector2
const zoom_step : float = 0.05
const zoom_step_button : float = 0.5
var offset_min : Vector2
var offset_max : Vector2

func _ready():
	offset_max = map_texture.texture.get_size() * map_texture.scale * 0.5
	offset_min = -offset_max
	map_interface.clip_contents = true
	update_map_pos_scale()


func _process(delta):
	if is_dragging && Input.is_action_pressed("click"):
		update_map_pos_scale()
		graph_edit.scroll_offset = drag_offset - get_local_mouse_position()
		graph_edit.scroll_offset = clamp(graph_edit.scroll_offset, offset_min, offset_max)


func update_map_pos_scale():
	map.scale = Vector2(graph_edit.zoom, graph_edit.zoom)
	map.position = -graph_edit.scroll_offset
	map_size.text = str(round(graph_edit.zoom * 100)) + "%"


func _on_map_interface_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_offset = get_local_mouse_position() + graph_edit.scroll_offset
			else:
				is_dragging = false
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP && event.pressed == true:
			graph_edit.zoom += zoom_step * graph_edit.zoom
			update_map_pos_scale()
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN && event.pressed == true:
			graph_edit.zoom -= zoom_step * graph_edit.zoom
			update_map_pos_scale()


func _on_minus_button_pressed():
	graph_edit.zoom -= zoom_step_button * graph_edit.zoom
	update_map_pos_scale()


func _on_restore_button_pressed():
	graph_edit.zoom = 1
	update_map_pos_scale()


func _on_plus_button_pressed():
	graph_edit.zoom += zoom_step_button * graph_edit.zoom
	update_map_pos_scale()
