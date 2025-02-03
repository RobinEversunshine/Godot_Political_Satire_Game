extends Control

@onready var rand = RandomNumberGenerator.new()

@export var color_gradient_list : Array[Gradient]
@export var shader_gradient : Gradient

var gameboy_gradient : Gradient = load("res://Assets/Resource/ColorGradients/gameboy_gradient.tres")


var gradient_index : int = 0:
	set(value):
		gradient_index = clamp(value, 0, color_gradient_list.size() - 1)
		var target_gradient = color_gradient_list[gradient_index]
		set_color(target_gradient)


func _ready():
	if Global.Note["Note_color"]:
		add_gradient()


func set_color(gradient : Gradient):
	get_tree().create_tween().tween_property(
		shader_gradient, "colors", gradient.colors, 0.5
		).set_trans(Tween.TRANS_CUBIC)


func set_color_white(color_white : Color, tween_time : float = 0.5):
	if tween_time != 0:
		get_tree().create_tween().tween_property(
		shader_gradient, "colors", 
		PackedColorArray([color_white, shader_gradient.colors[-1]]), 0.5
		).set_trans(Tween.TRANS_CUBIC)
	else:
		shader_gradient.colors[-1] = color_white


func set_color_black(color_black : Color, tween_time : float = 0.5):
	if tween_time != 0:
		get_tree().create_tween().tween_property(
		shader_gradient, "colors", 
		PackedColorArray([shader_gradient.colors[0], color_black]), 0.5
		).set_trans(Tween.TRANS_CUBIC)
	else:
		shader_gradient.colors[0] = color_black


func change_gradient(option : String = "forward"):
	if option == "forward":
		if gradient_index == color_gradient_list.size() - 1:
			gradient_index = 0
		else:
			gradient_index += 1
	elif option == "backward":
		if gradient_index == 0:
			gradient_index = color_gradient_list.size() - 1
		else:
			gradient_index -= 1


func random_color(list : Array = []):
	rand.randomize()
	if list.is_empty():
		var rand_index : int = rand.randi_range(0, color_gradient_list.size() - 1)
		if gradient_index != rand_index:
			gradient_index = rand_index
		else:
			gradient_index += 1
	else:
		var rand_index : int = rand.randi_range(0, list.size() - 1)
		gradient_index = list[rand_index]


func get_current_gradient():
	return color_gradient_list[gradient_index]


func add_gradient():
	color_gradient_list.append(gameboy_gradient)


