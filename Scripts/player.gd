extends CharacterBody3D

const BOBBER = preload("res://Scenes/bobber.tscn")
const FISHING_LINE = preload("res://Decoration/fishing_line.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pole: MeshInstance3D = $SpringArm3D/pole
@onready var spool: Marker3D = $SpringArm3D/pole/Spool
@onready var first_ring: Marker3D = $SpringArm3D/pole/FirstRing
@onready var tip: Marker3D = $SpringArm3D/pole/Tip

@export_category("🎣 Casting 🎣")
var casting_tip_positions:Dictionary[float,Vector3] = {}
@export var casting_impulse_time:float = 0.2
@export var cast_strength:float = 10
var casting_time_bucket:float
var bobber:Bobber
var bobber_top:Marker3D
var line_to_bobber:Sprite3D

@export_category("🏃‍♀️ Movement 🏃‍♀️")
@export var SPEED = 5.0
const JUMP_VELOCITY = 4.5
var mouse_move:Vector2 = Vector2.ZERO
var holstered:bool = true
@export var max_sprint = 3.0
var sprint = 1.0
@export var mouse_sensitivity:float

@export_category("🐟 Fishing 🐟")
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var reel_speed:float = 1.0
@export_custom(PROPERTY_HINT_TYPE_STRING, "suffix:m") var reel_in_distance:float = 5.0

enum State{
	NULL, WALKING, CASTING, WAITING_FOR_BOBBER_TO_LAND, FISHING, INVENTORY
}

var state:State = State.WALKING

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	create_base_fishing_line()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion :
		mouse_move += event.relative * mouse_sensitivity
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click"):
		mouse_move = Vector2.ZERO
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		

func _physics_process(delta: float) -> void:
	match(state):
		State.WALKING:
			walking_process(delta)
		State.CASTING:
			casting_process(delta)
		State.WAITING_FOR_BOBBER_TO_LAND:
			waiting_for_bobber_to_land_process(delta)
		State.FISHING:
			fishing_process(delta)

func walking_process(delta:float):
	if Input.is_action_just_pressed("click"):
		state = State.CASTING
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("Left Shift"):
		sprint = max_sprint
	
	if Input.is_action_just_released("Left Shift"):
		sprint = 1.0
		
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	mouse_look()
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
		velocity.x = direction.x * SPEED * sprint
		velocity.z = direction.z * SPEED * sprint
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	draw_line_to_bobber()
	if !bobber and line_to_bobber:
		line_to_bobber.queue_free()
func casting_process(delta:float):
	if holstered:
		state = State.WALKING
		return
	if Input.is_action_just_released("click") and casting_time_bucket < casting_impulse_time:
		state = State.WALKING
	
	casting_time_bucket += delta
	casting_tip_positions.set(casting_time_bucket, tip.global_position)
	var keys:Array[float] = casting_tip_positions.keys()
	#print("buck: %s, imp: %s, sub: %s"% [casting_time_bucket, casting_impulse_time, casting_time_bucket - casting_impulse_time])
	var culled_keys = keys.filter(
		func(k): return k < casting_time_bucket - casting_impulse_time
	)
	for key:float in culled_keys:
		casting_tip_positions.erase(key)
	if Input.is_action_just_released("click"):
		keys = casting_tip_positions.keys()
		var start_pos:Vector3 = casting_tip_positions[keys.front()]
		var end_pos:Vector3 = casting_tip_positions[keys.back()]
		var cast_vector:Vector3 = (end_pos - start_pos)
		#print("end: %s start:%s length: %s"%[end_pos, start_pos, cast_vector.length()])
		# instantiate and release bobber
		if bobber:
			bobber.queue_free()
		bobber = BOBBER.instantiate()
		bobber.linear_velocity = cast_vector * cast_strength
		# enable collision signals
		bobber.set_contact_monitor(true)
		bobber.set_max_contacts_reported(1)
		#print(bobber.max_contacts_reported)
		get_parent().add_child(bobber)
		bobber_top = bobber.top
		bobber.global_position = end_pos
		bobber.bobber_landed.connect(handle_bobber_landed, CONNECT_ONE_SHOT)
		
		# Also give the bobber starting impulse
		state = State.WAITING_FOR_BOBBER_TO_LAND
		casting_time_bucket = 0
		casting_tip_positions.clear()

	
	mouse_look()

func fishing_process(delta:float):
	draw_line_to_bobber()
	
	if Input.is_action_pressed("click"):
		if bobber:
			var target_pos:Vector3 = Vector3(global_position.x,bobber.global_position.y,global_position.z)
			bobber.global_position = bobber.global_position.move_toward(target_pos, reel_speed * delta)
			if bobber.global_position.distance_to(target_pos) < reel_in_distance:
				# didn't catch fish so return bobber and set to walking
				bobber.kill()
				state = State.WALKING
		else:
			state = State.WALKING
	if Input.is_action_just_pressed("right_click"):
		if bobber:
			bobber.kill()
		state = State.WALKING
	mouse_look()

func waiting_for_bobber_to_land_process(delta:float):
	if Input.is_action_just_pressed("right_click"):
		if bobber:
			bobber.kill()
		state = State.WALKING
	draw_line_to_bobber()
	mouse_look()

func draw_line_to_bobber():
	if bobber:
		#print(tip.global_position, bobber.global_position)
		if !line_to_bobber:
			line_to_bobber = create_line_sprite(bobber_top.global_position, tip.global_position)
			tip.add_child(line_to_bobber)
		line_to_bobber.global_position = tip.global_position
		line_to_bobber.look_at(bobber_top.global_position)
		line_to_bobber.scale.z = (bobber_top.global_position-tip.global_position).length() * 100

func handle_bobber_landed(in_water:bool):
	if in_water:
		state = State.FISHING
	else:
		state = State.WALKING
	pass

func mouse_look():
	rotation.y -= mouse_move.x
	rotation.x -= mouse_move.y
	rotation.x = clampf(rotation.x, -PI/3, PI/3)
	mouse_move = Vector2.ZERO

func create_base_fishing_line():
	var line = create_line_sprite(spool.position,first_ring.position)
	pole.add_child(line)
	line = create_line_sprite(first_ring.position, tip.position)
	pole.add_child(line)

func create_line_sprite(from:Vector3, to:Vector3) -> Sprite3D:
	var line:Sprite3D =  FISHING_LINE.instantiate()
	line.scale.z = (from-to).length() * 100
	line.position = from
	line.look_at_from_position(from,to)
	return line

func _on_good_cast():
	state = State.FISHING
