extends Node

const month_name_list : Array = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
const weekday_list : Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
const default_time : Dictionary = {"year" : 2083, "month" : 12, "day" : 31, "weekday": 5, "hour": 22, "minute": 55, "second": 0}

var speed : float = 1
var second_timer : Timer
# a day = 86400
# a year = 31536000
var unix_time : int
var date_time : Dictionary = {"year" : 2083, "month" : 12, "day" : 31, "weekday": 5, "hour": 22, "minute": 55, "second": 0}

signal time_changed
signal minute_changed
signal day_changed


func _ready():
	if !unix_time:
		unix_time = Time.get_unix_time_from_datetime_dict(default_time)
	update_time()


func get_days_in_month(month : int, year : int) -> int:
	var number_of_days : int
	if(month == 4 || month == 6 || month == 9
			|| month == 11):
		number_of_days = 30
	elif(month == 2):
		var is_leap_year = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
		if(is_leap_year):
			number_of_days = 29
		else:
			number_of_days = 28
	else:
		number_of_days = 31
	
	return number_of_days


func update_time():
	second_timer = Timer.new()
	second_timer.autostart = true
	add_child(second_timer)
	
	while unix_time:
		unix_time += int(speed)
		date_time = Time.get_datetime_dict_from_unix_time(unix_time)
		
		if unix_time % 60 < speed:
			emit_signal("minute_changed")
		if unix_time % 86400 < speed:
			emit_signal("day_changed")
		emit_signal("time_changed")
		
		await second_timer.timeout


#if the speed is larger than 60, it's better be a multiply of 60.
func change_speed(change_to_speed : float = 1, change_rate : float = 2):
	var target_speed : float
	if change_to_speed <= 60:
		target_speed = 1 / change_to_speed
		get_tree().create_tween().tween_property(self, "speed", 1, 1)
	else:
		target_speed = 1.0 / 60
		get_tree().create_tween().tween_property(self, "speed", change_to_speed / 60, 5)
		
	if target_speed > second_timer.wait_time:
		while target_speed > second_timer.wait_time:
			await second_timer.timeout
			second_timer.wait_time *= change_rate
	elif target_speed < second_timer.wait_time:
		while target_speed < second_timer.wait_time:
			await second_timer.timeout
			second_timer.wait_time /= change_rate
	second_timer.wait_time = target_speed


func add_zero(input : int) -> String:
	var result : String
	if input < 10:
		result = "0" + str(input)
	else:
		result = str(input)
	return result


func get_time_baked(time_dict : Dictionary):
	var time_dict_baked : Dictionary = {}
	
	if "minute" in time_dict:
		time_dict_baked["minute"] = add_zero(time_dict["minute"])
	
	if "hour" in time_dict:
		time_dict_baked["hour"] = add_zero(time_dict["hour"])
	
	if "day" in time_dict:
		time_dict_baked["day"] = add_zero(time_dict["day"])
	
	if "month" in time_dict:
		time_dict_baked["month"] = add_zero(time_dict["month"])
		time_dict_baked["month_name"] = month_name_list[time_dict["month"]]
	
	if "year" in time_dict:
		time_dict_baked["year"] = str(time_dict["year"])
	
	if "weekday" in time_dict:
		time_dict_baked["weekday"] = weekday_list[time_dict["weekday"]]
	
	return time_dict_baked


func get_system_time() -> Dictionary:
	return Time.get_datetime_dict_from_system()


func reset_time():
	unix_time = 3597512400


#func _input(event):
	#if event.is_action_pressed("ui_cancel"):
		#change_speed(240)
	#elif event.is_action_pressed("ui_accept"):
		#change_speed()
