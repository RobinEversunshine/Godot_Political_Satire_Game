extends TextureRect

@onready var color_picker_button = $ColorPickerButton
@onready var color_picker_button_2 = $ColorPickerButton2
@export var image_texture : Texture2D


@onready var player = $"../TextureRect2/SubViewport/Node3D/Player"


var mouse_sensitivity := 0.003

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			player.twist_input = -event.relative.x * mouse_sensitivity
			player.pitch_input = -event.relative.y * mouse_sensitivity


func _ready():
	TranslationServer.set_locale("zh")
	#var gradient_list = texture.gradient.colors
	#color_picker_button = gradient_list[0]
	#color_picker_button_2.color = gradient_list[-1]
	
	#var date = Calendar.DateLibrary.new(1989, 6, 4)
	#print(Key.is_the_date(date))
	
	
	#await get_tree().create_timer(1).timeout
	#Key.emit_morse("abcde")
	
	#print(load("res://Assets/Translation/translation.csv"))
	#FileAccess.get_csv_line()
	$"../RichTextLabel".add_image(image_texture)
	
	#var image_file = "res://Assets/Textures/photos/laywer.png"
	#var image = Image.new()
	#var error = image.load(image_file)
	#if error == OK:
		#var texture_a = ImageTexture.create_from_image(image)
		#$"../RichTextLabel".add_image(texture_a)
	
	
	#var text = FileAccess.open("res://Assets/Translation/translation.csv", FileAccess.READ)
	#print(text.get_csv_line())
	#print(text.get_as_text())
	#print(FileAccess.get_file_as_string("res://Assets/Dialogues/Notes/note_about_vaccines.dialogue"))
	
	
	load_csv("res://Assets/Texts/date_event.csv")

var items : Array[Dictionary]

func load_csv(csv_path : String):
	var csv_file
	var items_title : PackedStringArray
	
	if FileAccess.file_exists(csv_path):
		csv_file = FileAccess.open(csv_path, FileAccess.READ)
		#get first line's information
		items_title = csv_file.get_csv_line()
		
		while csv_file.get_position() < csv_file.get_length():
			var csv_item : PackedStringArray = csv_file.get_csv_line()
			var item : Dictionary
			
			#get every value in this line and assign it to the dictionary
			for index in items_title.size():
				item[items_title[index]] = csv_item[index]
				
			items.append(item)
	print(items)


func _on_color_picker_button_color_changed(color):
	#texture.gradient.colors[0] = color
	get_tree().create_tween().tween_property(
		texture.gradient, "colors", 
		PackedColorArray([color, texture.gradient.colors[-1]]), 0.5
		).set_trans(Tween.TRANS_CUBIC)


func _on_color_picker_button_2_color_changed(color):
	#texture.gradient.colors[-1] = color
	get_tree().create_tween().tween_property(
		texture.gradient, "colors", 
		PackedColorArray([texture.gradient.colors[0], color]), 0.5
		).set_trans(Tween.TRANS_CUBIC)


func _on_rich_text_label_meta_clicked(meta):
	print(meta)
