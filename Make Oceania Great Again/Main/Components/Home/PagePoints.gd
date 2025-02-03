extends CenterContainer

#var current_page : int
#var page_nodes : Array
var point_nodes : Array

@onready var h_box_container2 = $HBoxContainer
@onready var texture_rect = $HBoxContainer/TextureRect
@export var fill_texture : Texture2D
@export var empty_texture : Texture2D

func _ready():
	point_nodes = h_box_container2.get_children()
	set_current_page(0)
#	for page in page_nodes:
#		var new_point = texture_rect.duplicate(8)
#		new_point.name = page.name
#		h_box_container.add_child(new_point)


func set_current_page(current_index : int):
	for point in point_nodes:
		if point_nodes.find(point) == current_index:
			point.texture = fill_texture
		else:
			point.texture = empty_texture
