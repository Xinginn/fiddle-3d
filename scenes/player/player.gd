extends KinematicBody

const MOUSE_SENSITIVITY: float = 0.2
const MOVE_SPEED: float = 3.0
const GRAVITY_ACCELERATION = 9.8
const JUMP_FORCE: float = 3.5
const MAX_JUMP: int = 2

onready var look_pivot: Spatial = $LookPivot

var remaining_jump = MAX_JUMP

var input_move: Vector3 = Vector3()
var gravity_local: Vector3 = Vector3()
var snap_vector: Vector3 = Vector3()

func _ready():
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
   
func _input(event):
  if event is InputEventMouseMotion:
    rotate_y(deg2rad(-1 * event.relative.x) * MOUSE_SENSITIVITY)
    look_pivot.rotate_x(deg2rad(event.relative.y ) * MOUSE_SENSITIVITY)
    look_pivot.rotation.x = clamp(look_pivot.rotation.x, -1.5708, 1.5708) # clamps pivot vertical rotation between -90 and +90 °

func _physics_process(delta):
  input_move = get_input_direction() * MOVE_SPEED
  if not is_on_floor():
    gravity_local  += GRAVITY_ACCELERATION * Vector3.DOWN * delta
  else:
    remaining_jump = MAX_JUMP
    gravity_local = Vector3.ZERO
    
  snap_vector = Vector3.DOWN
  if is_on_floor():
    snap_vector = -get_floor_normal()
  
  if Input.is_action_just_pressed("jump") && remaining_jump > 0:
    remaining_jump -= 1
    snap_vector = Vector3.ZERO
    gravity_local = JUMP_FORCE * Vector3.UP
  move_and_slide_with_snap(input_move + gravity_local, snap_vector, Vector3.UP)
  
  
  
func get_input_direction() -> Vector3:
  var z: float = Input.get_action_strength("forward") - Input.get_action_strength("backward")
  var x: float = Input.get_action_strength("left") - Input.get_action_strength("right")
  return transform.basis.xform(Vector3(x, 0, z).normalized())  # basis.xform converts local orientation to global orientation
