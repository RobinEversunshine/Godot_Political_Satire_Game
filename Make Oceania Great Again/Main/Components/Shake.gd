extends Control

@onready var noise = FastNoiseLite.new()
@onready var rand = RandomNumberGenerator.new()

var shake_strength : float = 0
var fade_speed : float = 10
var noise_i : float = 0
const rest_position : Vector2 = Vector2(380, 30)

var time_threshold : float = 0
var shake_time_hold : float = 0

func _ready():
	rand.randomize()
	noise.seed = rand.randi()
	noise.frequency = 2


func _process(delta):
	if shake_strength > 0.01:
		if shake_time_hold > time_threshold:
			shake_strength = lerpf(shake_strength, 0, delta * fade_speed)
		else:
			shake_time_hold += delta
		self.position = rest_position + get_noise_offset(delta)
	else:
		shake_time_hold = 0


func camera_shake(shake_amount : float = 10, shake_time : float = 0):
	shake_strength = shake_amount
	time_threshold = shake_time


func stop_shake():
	time_threshold = 0


func get_noise_offset(delta : float):
	noise_i += delta * 30
	return Vector2(noise.get_noise_2d(1, noise_i) * shake_strength, noise.get_noise_2d(100, noise_i) * shake_strength)


#func _input(event):
	#if event.is_action_pressed("ui_cancel"):
		#camera_shake(10,2)
		#Input.start_joy_vibration(0,0.1,0.1,0.1)
