extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var mouse_move:Vector2 = Vector2.ZERO
@export var mouse_sensitivity:float
var holstered:bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion :
		mouse_move += event.relative * mouse_sensitivity
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click"):
		mouse_move = Vector2.ZERO
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	rotation.y -= mouse_move.x
	rotation.x -= mouse_move.y
	rotation.x = clampf(rotation.x, -PI/3, PI/3)
	mouse_move = Vector2.ZERO
	
	if Input.is_action_just_pressed("e"):
		if holstered:
			animation_player.play_backwards("holster")
			holstered = false
		else:
			animation_player.play("holster")
			holstered = true
			
			
	
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
