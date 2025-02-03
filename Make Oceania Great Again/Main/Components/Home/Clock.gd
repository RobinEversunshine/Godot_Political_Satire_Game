extends Control

@onready var second_sprite = $SecondSprite
@onready var minute_sprite = $MinuteSprite
@onready var hour_sprite = $HourSprite

var date_time : Dictionary


func _ready():
	update_time()
	DateTime.connect("time_changed", update_time)


func update_time():
	date_time = DateTime.date_time
	set_second()
	set_minute()
	set_hour()


func set_second():
	var second = date_time["second"]
	if second < 30:
		second_sprite.frame = second
	else:
		second_sprite.frame = second - 30
	
	if second <= 15:
		second_sprite.flip_v = false
		second_sprite.flip_h = false
	elif second > 15 && second <= 30:
		second_sprite.flip_v = true
		second_sprite.flip_h = false
	elif second > 30 && second <= 45:
		second_sprite.flip_v = true
		second_sprite.flip_h = true
	elif second > 45:
		second_sprite.flip_v = false
		second_sprite.flip_h = true

func set_minute():
	var minute = date_time["minute"]
	if minute < 30:
		minute_sprite.frame = minute
	else:
		minute_sprite.frame = minute - 30
	
	if minute <= 15:
		minute_sprite.flip_v = false
		minute_sprite.flip_h = false
	elif minute > 15 && minute <= 30:
		minute_sprite.flip_v = true
		minute_sprite.flip_h = false
	elif minute > 30 && minute <= 45:
		minute_sprite.flip_v = true
		minute_sprite.flip_h = true
	elif minute > 45:
		minute_sprite.flip_v = false
		minute_sprite.flip_h = true

func set_hour():
	var hour = (date_time["hour"] * 60 + date_time["minute"]) / 12
	if hour > 60:
		hour -= 60
	
	if hour < 30:
		hour_sprite.frame = hour
	else:
		hour_sprite.frame = hour - 30
	
	if hour <= 15:
		hour_sprite.flip_v = false
		hour_sprite.flip_h = false
	elif hour > 15 && hour <= 30:
		hour_sprite.flip_v = true
		hour_sprite.flip_h = false
	elif hour > 30 && hour <= 45:
		hour_sprite.flip_v = true
		hour_sprite.flip_h = true
	elif hour > 45:
		hour_sprite.flip_v = false
		hour_sprite.flip_h = true
