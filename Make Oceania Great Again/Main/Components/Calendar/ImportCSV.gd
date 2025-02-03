extends Node


@onready var calendar_demo = $".."


func _ready():
	load_csv("res://Assets/Texts/date_event.csv")


func load_csv(csv_path : String):
	var csv_file
	var items_title : PackedStringArray
	
	if FileAccess.file_exists(csv_path):
		csv_file = FileAccess.open(csv_path, FileAccess.READ)
		#get first line's information
		items_title = csv_file.get_csv_line()
		
		while csv_file.get_position() < csv_file.get_length():
			var csv_item : PackedStringArray = csv_file.get_csv_line()
			
			if !csv_item[0].is_empty():
				var date_event : DateEvent = DateEvent.new()
				
				#get every value in this line and assign it to the dictionary
				for index in items_title.size():
					if items_title[index] in date_event:
						var prop_name = items_title[index]
						if date_event.get(prop_name) is String:
							date_event.set(prop_name, csv_item[index])
						elif date_event.get(prop_name) is bool:
							date_event.set(prop_name, bool(csv_item[index].to_int()))
				
				date_event.date = {
					"year" : csv_item[0].to_int(),
					"month" : csv_item[1].to_int(),
					"day" : csv_item[2].to_int()
				}
				
				calendar_demo.date_event_list.append(date_event)
			


