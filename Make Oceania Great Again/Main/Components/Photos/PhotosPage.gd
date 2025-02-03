extends Control

@onready var photo_scroll = $PhotoScroll
@onready var grid_container = $"../PhotoSelectPage/ScrollContainer/MarginContainer/GridContainer"
@onready var animation_player = $"../AnimationPlayer"
@onready var photos = $".."

@onready var photo_name_label = $header/CenterContainer/PhotoNameLabel
@onready var when_label = $Inform/PanelContainer/VBoxContainer/When
@onready var where = $Inform/PanelContainer/VBoxContainer/Where
@onready var who = $Inform/PanelContainer/VBoxContainer/Who
@onready var what = $Inform/PanelContainer/VBoxContainer/What


const PHOTO_BUTTON = preload("res://Main/Components/Photos/photo_button.tscn")
const BROKEN_304 = preload("res://Assets/Textures/photos/broken_304.png")

var page_current_index : int = 0
var page_pos_x : Array = []

var is_clicking : bool = false
var click_time : float
const click_time_threshold : float = 0.2
var click_pos_start : Vector2

var active_album : Control
var photo_list : Array


func _ready():
	photo_scroll.clip_contents = true


func _process(delta):
	if is_clicking:
		click_time += delta


func build_photos(album_button : Control):
	if active_album != album_button:
		active_album = album_button
		
		for child in grid_container.get_children():
			child.queue_free()
		
		var h_box_container = active_album.photo_container
		photo_list = h_box_container.get_children()
		for photo in photo_list:
			var new_photo_button = PHOTO_BUTTON.instantiate()
			grid_container.add_child(new_photo_button)
			new_photo_button.update_texture(photo.texture_normal, photo.hide_photo)
			new_photo_button.connect("into_photo", photo_button_pressed)
			
			if photo.duplicate_amount != 0:
				var photo_index : int = h_box_container.get_children().find(photo)
				for i in photo.duplicate_amount:
					var photo_button_dup = new_photo_button.duplicate()
					var photo_dup = photo.duplicate()
					photo_dup.duplicate_amount = 0
					
					var rng = new_rand(photo_index + i + 1)
					photo_dup.photo_name = rand_photo_name(rng)
					photo_dup.taken_time = rand_date(rng)
					
					grid_container.add_child(photo_button_dup)
					photo_button_dup.connect("into_photo", photo_button_pressed)
					h_box_container.add_child(photo_dup)
					h_box_container.move_child(photo_dup, photo_index + i + 1)
					
				photo.duplicate_amount = 0
				
				var rng = new_rand(photo_index)
				photo.photo_name = rand_photo_name(rng)
				photo.taken_time = rand_date(rng)
		
		await get_tree().process_frame
		photo_list = h_box_container.get_children()
		page_pos_x = []
		for page in photo_list:
			page_pos_x.append(page.position.x)


func photo_button_pressed(index : int):
	page_current_index = index
	set_page_pos(0)
	animation_player.play("into_photo")
	photos.layer = 2


func set_page_pos(tween_time : float = 0.3):
	page_current_index = clamp(page_current_index, 0, page_pos_x.size() - 1)
	var target_pos = page_pos_x[page_current_index]
	get_tree().create_tween().tween_property(photo_scroll, "scroll_horizontal", target_pos, tween_time).set_trans(Tween.TRANS_CUBIC)
	
	var active_photo = photo_list[page_current_index]
	#get_tree().create_tween().tween_property(photo_name_label, "text", active_photo.photo_name, tween_time).set_trans(Tween.TRANS_CUBIC)
	
	var time = DateTime.get_time_baked(active_photo.taken_time)
	var target_time : String = time["month"] + "-" + time["day"] + "-" + time["year"]
	get_tree().create_tween().tween_property(when_label, "text", target_time, 0.5).set_trans(Tween.TRANS_CUBIC)
	
	if active_photo.texture_normal != BROKEN_304:
		var photo_name : String = (photo_name_label.mission_define(active_photo.photo_name))
		var location : String = (where.mission_define(active_photo.location))
		var people: String = (who.mission_define(active_photo.people))
		var description: String = (what.mission_define(active_photo.description))
		
		get_tree().create_tween().tween_property(photo_name_label, "text", photo_name, tween_time).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(where, "text", location, 0.5).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(who, "text", people, 0.5).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(what, "text", description, 0.5).set_trans(Tween.TRANS_CUBIC)
	else:
		photo_name_label.mission_name = ""
		where.mission_name = ""
		who.mission_name = ""
		what.mission_name = ""
		
		get_tree().create_tween().tween_property(photo_name_label, "text", active_photo.photo_name, tween_time).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(where, "text", "N/A", 0.5).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(who, "text", "N/A", 0.5).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(what, "text", "", 0.5).set_trans(Tween.TRANS_CUBIC)


func new_rand(new_seed : int):
	var rng = RandomNumberGenerator.new()
	rng.seed = new_seed
	return rng


func rand_photo_name(rng : RandomNumberGenerator):
	var photo_name : String = ""
	for i in rng.randi_range(5, 10):
		var letter : String
		if rng.randi_range(0, 2) == 0:
			letter = str(rng.randi_range(0, 9))
		else:
			letter = String.chr(rng.randi_range(97, 122))
			if rng.randi_range(0, 1) == 1:
				letter = letter.to_upper()
		photo_name += letter
	
	var random_extension : int = rng.randi_range(0, 2)
	if random_extension == 0:
		photo_name += ".jpg"
	elif random_extension == 1:
		photo_name += ".png"
	else:
		photo_name += ".bmp"
	
	return "IMG_" + photo_name


func rand_date(rng : RandomNumberGenerator):
	var taken_time : Dictionary = {}
	var year : int = rng.randi_range(1985, 2083)
	var month : int = rng.randi_range(1, 12)
	taken_time["year"] = year
	taken_time["month"] = month
	var day_in_month : int = DateTime.get_days_in_month(month, year)
	taken_time["day"] = rng.randi_range(1, day_in_month)
	return taken_time


func _on_photo_scroll_gui_input(event):
	if event is InputEventMouseButton:
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
						var diff = abs(photo_scroll.scroll_horizontal - pos)
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

