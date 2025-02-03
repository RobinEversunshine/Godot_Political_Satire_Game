extends RigidBody3D

@onready var twist_pivot = $TwistPivot
@onready var pitch_pivot = $TwistPivot/PitchPivot



var mouse_sensitivity := 0.003
var twist_input := 0.0
var pitch_input := 0.0


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _process(delta):
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backward")
	#var input = Input.get_action_strength("ui_up")
	#input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	apply_central_force(twist_pivot.basis * input * 1200 * delta)
	
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-72), deg_to_rad(72))
	
	twist_input = 0.0
	pitch_input = 0.0


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity







func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
