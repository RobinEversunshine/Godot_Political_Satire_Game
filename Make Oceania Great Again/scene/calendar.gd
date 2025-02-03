extends BaseGUIView

@onready var scroll_container = $Padding/CalendarComponents/YearCalendarContainer/ScrollContainer
@onready var year_option_button = $Padding/CalendarComponents/YearCalendarContainer/VBoxContainer/HBoxContainer/YearOptionButton

@onready var year_button = $Padding/CalendarComponents/YearCalendarContainer/VBoxContainer/HBoxContainer/YearButton
@onready var month_button = $Padding/CalendarComponents/YearCalendarContainer/VBoxContainer/MarginContainer/HBoxContainer2/MonthButton

@onready var year_item_list = %YearSelectPopup.get_child(0)
@onready var month_item_list = %MonthSelectPopup.get_child(0)

@export var date_event_texture : Texture2D
@export var date_event_list : Array[DateEvent]


func _ready() -> void:
	cal.set_first_weekday(Time.WEEKDAY_SUNDAY)
	cal.week_number_system = Calendar.WeekNumberSystem.WEEK_NUMBER_FOUR_DAY
	
	item_list_add_year()
	#TranslationServer.set_locale("zh")
	if TranslationServer.get_locale() == "zh":
		cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_CN.tres")
	
	selected_date = Calendar.DateLibrary.today()
	year = DateTime.date_time["year"]
	
	
	weekdays_formatted = cal.get_weekdays_formatted(Calendar.WeekdayFormat.WEEKDAY_FORMAT_SHORT)
	months_formatted = cal.get_months_formatted(Calendar.MonthFormat.MONTH_FORMAT_FULL)
	
	await get_tree().process_frame
	populate_year_calendar()
	set_date_label(selected_date)
	%DateLabel.text = cal.get_date_formatted(selected_date.year, selected_date.month, selected_date.day, "%B %d, %A")
	
	await get_tree().process_frame
	month_index = DateTime.date_time["month"]
	scroll_container.scroll_horizontal = (month_index - 1) * 280



############################################################
#########
#########   YEAR CALENDAR AND SETTINGS
#########
############################################################


var cal: Calendar = Calendar.new()
var year = 2024
var month_index = 12:
	set(value):
		month_index = value
		#%MonthLabel.text = DateTime.month_name_list[month_index]
		month_button.text = DateTime.month_name_list[month_index]
		var target_pos : float = (month_index - 1) * 280
		get_tree().create_tween().tween_property(scroll_container, "scroll_horizontal", target_pos, 0.5).set_trans(Tween.TRANS_CUBIC)

var months_formatted: Array[String]
var weekdays_formatted: Array[String]

var selected_date: Calendar.DateLibrary
var selected_date_label: Label

var show_weeks: bool = true

var week_number_system: Calendar.WeekNumberSystem

var show_week_number: bool = true


func populate_year_calendar():
	# Get a full years dates in a nested array. Iterate through the array [months, weeks, days]
	# and create necessary UI nodes for the calendar.
	var year_calendar = cal.get_calendar_year(year, true)
	#%YearLabel.text = str(year)
	year_button.text = str(year)
	
	var month = 1
	for months in year_calendar:
		# Add a GridContainer for each month
		var month_container = _add_month_grid_container(month)
		
		month_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		month_container.use_parent_material = true
		
		# If "Show week numbers" is ON an empty space has to be added before the weekday names
		if show_weeks:
			var weekday_label = CalendarLabel.new("")
			month_container.add_child(weekday_label)
			weekday_label.use_parent_material = true
		# Add the weekday strings to the grid. Each weekday label will be in a cell
		for weekday in weekdays_formatted:
			var weekday_label = CalendarLabel.new(weekday)
			month_container.add_child(weekday_label)
			weekday_label.use_parent_material = true
		
		# Make a referense to the current date so it can be colored in the calendar.
		var todays_date := Calendar.DateLibrary.today()
		
		# Iterate through every week in every month
		for week in months:
			# If show_weeks is true show the week number before all the day labels
			if show_weeks:
				var first_date = week[0]
				var week_number = cal.get_week_number(first_date.year, first_date.month, first_date.day)
				var week_label = CalendarLabel.new(str(week_number))
				
				
				week_label.label_settings.font_color = Color("#848d9c")
				month_container.add_child(week_label)
				week_label.use_parent_material = true
				
			for date in week:
				var date_label = CalendarLabel.new(str(date.day), true)
				
				if date.month == month:
					if date.is_equal(todays_date):
						date_label.label_settings.font_color = Color("#70bafa")
					else:
						date_label.label_settings.font_color = Color("#cdced2")
				else:
					date_label.label_settings.font_color = Color("#414853")
				
				date_label.pressed.connect(_on_date_pressed.bind(date, date_label))
				date_label.pressed.connect(select_cancled)
				month_container.add_child(date_label)
				date_label.use_parent_material = true
				
				if date.is_equal(selected_date):
					set_selected_state(date_label)
				
				event_detect(date, date_label)
		
		month += 1


func _on_date_pressed(date: Calendar.DateLibrary, date_label: Label):
	set_selected_state(date_label)
	set_date_label(date)
	set_event_label(date)
	selected_date = date


func set_selected_state(date_label: Label):
	if selected_date_label && selected_date_label.get_child_count() > 0:
		for child in selected_date_label.get_children():
			if child.name == "select":
				child.queue_free()
				break
	var selected_rect: ColorRect = ColorRect.new()
	selected_rect.size = Vector2(20, 20)
	selected_rect.position += Vector2(-2, -1)
	selected_rect.color = Color("#414853")
	selected_rect.show_behind_parent = true
	date_label.add_child(selected_rect)
	selected_date_label = date_label
	
	if selected_date_label.get_child_count() > 1:
		selected_date_label.move_child(selected_rect, 0)
	selected_rect.name = "select"
	selected_rect.use_parent_material = true


func set_date_label(date: Calendar.DateLibrary):
	#%DateLabel.text = cal.get_date_formatted(date.year, date.month, date.day, "%A, %-d %B")
	var target_date : String = cal.get_date_formatted(date.year, date.month, date.day, "%B %d, %A")
	if Key.is_the_date(date) || (date.event && date.event.not_exist):
		target_date = ""
	get_tree().create_tween().tween_property(%DateLabel, "text", target_date, 0.5).set_trans(Tween.TRANS_CUBIC)


#event system
func date_is_event(date_label: Label):
	var event_text = TextureRect.new()
	event_text.texture = date_event_texture
	event_text.size = Vector2(20, 20)
	event_text.position += Vector2(-2, -1)
	event_text.show_behind_parent = true
	date_label.add_child(event_text)
	
	event_text.modulate = date_label.label_settings.font_color
	event_text.mouse_filter = 2
	event_text.use_parent_material = true


var last_date_is_not_exist : bool = false

func set_event_label(date: Calendar.DateLibrary):
	if last_date_is_not_exist:
		last_date_is_not_exist = false
		%EventLabel.text = ""
	
	var target_event : String = "No events"
	
	if date.event:
		%DateLabel.mission_name = date.event.date_mission_name
		target_event = %EventLabel.mission_define(date.event.event_name)
		
		if date.event.not_exist:
			await get_tree().create_tween().tween_property(%EventLabel, "text", "", 0.5).set_trans(Tween.TRANS_CUBIC).finished
			%EventLabel.text = %EventLabel.mission_define(date.event.event_name)
			last_date_is_not_exist = true
		else:
			get_tree().create_tween().tween_property(%EventLabel, "text", target_event, 0.5).set_trans(Tween.TRANS_CUBIC)
	else:
		%DateLabel.mission_name = ""
		%EventLabel.mission_name = ""
		get_tree().create_tween().tween_property(%EventLabel, "text", target_event, 0.5).set_trans(Tween.TRANS_CUBIC)
	
	if Key.is_the_date(date):
		target_event = ""




func event_detect(date: Calendar.DateLibrary, date_label: Label):
	for date_event in date_event_list:
		if date_event.is_equal(date):
			date.event = date_event
			#if !date_event.hide_icon:
				#date_is_event(date_label)
			if date_event.not_exist:
				date_label.text = ""
			else:
				date_is_event(date_label)



func _add_month_grid_container(p_month: int):
	var month_container = VBoxContainer.new()
	month_container.custom_minimum_size = Vector2(280, 160)
	month_container.use_parent_material = true
	month_container.mouse_filter = 2
	
	month_container.set("theme_override_constants/separation", 10)
	
	#var month_title = CalendarLabel.new(months_formatted[p_month - 1])
	#month_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	#month_title.label_settings.font_color = Color("#ffffff")
	#month_container.add_child(month_title)
	
	var month_grid = GridContainer.new()
	month_grid.mouse_filter = 2
	month_grid.columns = 8 if show_weeks else 7
	month_grid.set("theme_override_constants/h_separation", 14)
	month_grid.set("theme_override_constants/v_separation", 6)
	month_container.add_child(month_grid)
	%YearCalendar.add_child(month_container)
	return month_grid


func clear_year_calendar():
	selected_date_label = null
	for child in %YearCalendar.get_children():
		child.queue_free()


#### Signal handlers #####

func _on_first_weekday_option_button_item_selected(index: int) -> void:
	match index:
		0: cal.set_first_weekday(Time.WEEKDAY_MONDAY)
		1: cal.set_first_weekday(Time.WEEKDAY_TUESDAY)
		2: cal.set_first_weekday(Time.WEEKDAY_WEDNESDAY)
		3: cal.set_first_weekday(Time.WEEKDAY_THURSDAY)
		4: cal.set_first_weekday(Time.WEEKDAY_FRIDAY)
		5: cal.set_first_weekday(Time.WEEKDAY_SATURDAY)
		6: cal.set_first_weekday(Time.WEEKDAY_SUNDAY)
	
	weekdays_formatted = cal.get_weekdays_formatted(Calendar.WeekdayFormat.WEEKDAY_FORMAT_SHORT)
	
	clear_year_calendar()
	populate_year_calendar()


func _on_week_number_system_option_button_item_selected(index: int) -> void:
	match index:
		0: cal.set_week_number_system(Calendar.WeekNumberSystem.WEEK_NUMBER_FOUR_DAY)
		1: cal.set_week_number_system(Calendar.WeekNumberSystem.WEEK_NUMBER_TRADITIONAL)
		
	clear_year_calendar()
	populate_year_calendar()


func _on_week_numbers_check_button_toggled(toggled_on: bool) -> void:
	show_weeks = toggled_on
	
	clear_year_calendar()
	populate_year_calendar()


func _on_year_minus_pressed() -> void:
	if year != 1985:
		year -= 1
		
		clear_year_calendar()
		populate_year_calendar()


func _on_year_plus_pressed() -> void:
	if year != 2099:
		year += 1
		
		clear_year_calendar()
		populate_year_calendar()


#language
func _on_language_option_button_item_selected(index: int) -> void:
	match index:
		0:
			cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_EN.tres")
		1:
			cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_DE.tres")
		2:
			cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_ES.tres")
		3:
			cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_CN.tres")
		4:
			cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_SE.tres")
	
	weekdays_formatted = cal.get_weekdays_formatted(Calendar.WeekdayFormat.WEEKDAY_FORMAT_SHORT)
	months_formatted = cal.get_months_formatted(Calendar.MonthFormat.MONTH_FORMAT_FULL)
	
	clear_year_calendar()
	populate_year_calendar()
	set_date_label(selected_date)


############################################################
#########
#########   MONTH CALENDAR DROP DOWN
#########
############################################################


var month = 2

func populate_date_picker():
	var month_calendar = cal.get_calendar_month(year, month, true)
	var month_container = _date_picker_add_month_grid_container(month)
	
	# If "Show week numbers" is ON an empty space has to be added before the weekday names
	if show_weeks:
		var weekday_label = CalendarLabel.new("")
		month_container.add_child(weekday_label)
	# Add the weekday strings to the grid. Each weekday label will be in a cell
	for weekday in weekdays_formatted:
		var weekday_label = CalendarLabel.new(weekday)
		month_container.add_child(weekday_label)
	
	var todays_date := Calendar.DateLibrary.today()
	for week in month_calendar:
		# If show_weeks is true show the week number before all the day labels
		if show_weeks:
			var first_date = week[0]
			var week_number = cal.get_week_number(first_date.year, first_date.month, first_date.day)
			var week_label = CalendarLabel.new(str(week_number))
			week_label.label_settings.font_color = Color("#848d9c")
			month_container.add_child(week_label)
			
		for date in week:
			var date_label: CalendarLabel
			if date.month == month:
				date_label = CalendarLabel.new(str(date.day))
			else:
				date_label = CalendarLabel.new("")
				
			if date.month == month:
				if date.is_equal(todays_date):
					date_label.label_settings.font_color = Color("#70bafa")
				else:
					date_label.label_settings.font_color = Color("#cdced2")
			else:
				date_label.label_settings.font_color = Color("#414853")
			
			date_label.pressed.connect(_on_date_pressed.bind(date, date_label))
			month_container.add_child(date_label)
			
			if date.is_equal(selected_date):
				set_selected_state(date_label)


func _date_picker_add_month_grid_container(p_month: int):
	var container_padding = MarginContainer.new()
	container_padding.set("theme_override_constants/margin_left", 20)
	container_padding.set("theme_override_constants/margin_right", 20)
	container_padding.set("theme_override_constants/margin_top", 20)
	container_padding.set("theme_override_constants/margin_bottom", 20)
	
	var month_container = VBoxContainer.new()
	month_container.set("theme_override_constants/separation", 10)
	
	var title_string = "%s, %s" % [months_formatted[p_month - 1], year]
	var month_title = CalendarLabel.new(title_string)
	month_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	month_title.label_settings.font_color = Color("#ffffff")
	month_container.add_child(month_title)
	
	var month_grid = GridContainer.new()
	month_grid.columns = 8 if show_weeks else 7
	month_grid.set("theme_override_constants/h_separation", 14)
	month_grid.set("theme_override_constants/v_separation", 6)
	month_container.add_child(month_grid)
	container_padding.add_child(month_container)
	%PopupPanel.add_child(container_padding)
	return month_grid


func _on_date_picker_toggled(toggled_on: bool) -> void:
	%PopupPanel.visible = toggled_on



# Helper class for generating date labels.
class CalendarLabel:
	extends Label
	
	var clickable: bool = false
	
	signal pressed()
	
	
	func _init(p_text: String, p_clickable: bool = false):
		text = p_text
		horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label_settings = LabelSettings.new()
		set_font_size()
		if p_clickable:
			clickable = p_clickable
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			mouse_filter = Control.MOUSE_FILTER_STOP
	
	
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			if clickable:
				pressed.emit()
	
	
	func set_font_size(font_size: int = 16):
		label_settings.font_size = font_size





func _on_month_minus_pressed():
	if month_index != 1:
		month_index -= 1
	else:
		_on_year_minus_pressed()
		month_index = 12


func _on_month_plus_pressed():
	if month_index != 12:
		month_index += 1
	else:
		_on_year_plus_pressed()
		month_index = 1


func item_list_add_year():
	year_item_list.clear()
	var year_list : Array = range(2099, 1984, -1)
	for year_index in year_list:
		year_item_list.add_item(str(year_index))
	year_item_list.get_v_scroll_bar().use_parent_material = true
	
	for month_text in range(month_item_list.item_count):
		var month_tr : String = tr(month_item_list.get_item_text(month_text))
		month_item_list.set_item_text(month_text, month_tr)


func select_cancled():
	year_button.button_pressed = false
	%YearSelectPopup.visible = false
	month_button.button_pressed = false
	%MonthSelectPopup.visible = false


func _on_year_button_toggled(toggled_on):
	%YearSelectPopup.visible = toggled_on


func _on_month_button_toggled(toggled_on):
	%MonthSelectPopup.visible = toggled_on


func _on_year_item_list_item_selected(index):
	year = int(year_item_list.get_item_text(index))
	year_button.button_pressed = false
	%YearSelectPopup.visible = false
	
	clear_year_calendar()
	populate_year_calendar()


func _on_month_item_list_item_selected(index):
	month_index = index + 1
	month_button.button_pressed = false
	%MonthSelectPopup.visible = false


func _on_padding_gui_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			select_cancled()









