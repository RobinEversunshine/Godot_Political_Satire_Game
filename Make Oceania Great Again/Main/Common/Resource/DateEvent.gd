extends Resource
class_name DateEvent


@export var date : Dictionary = {"year" : 2083, "month" : 12, "day" : 31}
@export var event_name : String
@export var date_mission_name : String
@export var every_year : bool = true
@export var not_exist : bool = false
@export var hide_icon : bool = false

func is_equal(input_date: Calendar.DateLibrary):
	if every_year:
		if date["year"] <= input_date.year and date["month"] == input_date.month and date["day"] == input_date.day:
			return true
		return false
	else:
		if date["year"] == input_date.year and date["month"] == input_date.month and date["day"] == input_date.day:
			return true
		return false
