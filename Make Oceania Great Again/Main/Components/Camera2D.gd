extends Camera2D

@onready var noise = FastNoiseLite.new()
@onready var rand = RandomNumberGenerator.new()

var shake_strength : float = 0
var fade_speed : float = 10
var noise_i : float = 0


func _ready():
	rand.randomize()
	noise.seed = rand.randi()
	noise.frequency = 2


func _process(delta):
	if shake_strength != 0:
		shake_strength = lerpf(shake_strength, 0, delta * fade_speed)
		self.offset = get_noise_offset(delta)


func camera_shake(shake_amount : float = 60):
	shake_strength = shake_amount


func get_noise_offset(delta : float):
	noise_i += delta * 30
	return Vector2(noise.get_noise_2d(1, noise_i) * shake_strength, noise.get_noise_2d(100, noise_i) * shake_strength)


#func _input(event):
	#if event.is_action_pressed("ui_cancel"):
		#camera_shake()
		#Input.start_joy_vibration(0,0.1,0.1,0.1)
		##print(Input.get_joy_name(0))
