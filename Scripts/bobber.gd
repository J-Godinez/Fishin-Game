extends RigidBody3D

class_name Bobber

@export var duration = 4.0
@export var freq = 1.0
@export var amp = 1.0
@export var offset:float = 0.0
@export var rot_freq = 1.0
@export var rot_amp = 1.0
var start_pos

signal good_cast

#NOTE:
	# ✅ set_contact_monitor(true) to enable the emission of signals when it collides (specifically on instantiation i think, so in the player script)
	# ✅ on the signal _on_body_entered we might use get_colliding_bodies() to detect what the bobber collides with
	# ✅ if it collides with the water, and/or a fishing spot, we freeze it in place 
	# ✅ to freeze it we must use set_freeze_enabled(true) after using set_freeze_mode(FREEZE_MODE_STATIC)
	# ✅ begin a bobbing animation and set_contact_monitor(false) to turn off collision signals
	# we should also probably enter a fishing state that ends when you reel in the bobber
	# if we hit a fishing spot, set a timer of some sort, at the end of which we enter a bite state
	# during that state, the bobber plummets under the water, and left clicking will add the fish to your inventory


func _on_body_entered(body: Node) -> void:
	if body is not FishingSpot:
		emit_bobber_landed(false)
		queue_free()
		return
	#print("Linear Velocity", linear_velocity, "Angular Velocity", angular_velocity)
	#linear_velocity = Vector3.ZERO
	#angular_velocity = Vector3.ZERO
	freeze_mode = Bobber.FREEZE_MODE_STATIC
	freeze = true
	start_pos = position
	start_pos.y -= offset
	rotation = Vector3.ZERO
	bob_tween()


func bob_tween():
	var tween:Tween = create_tween()
	tween.set_loops()
	tween.tween_method(bob_tween_method, 0.0, 2.0*PI, duration)
	

func bob_tween_method(prog):
	position.y = start_pos.y + sin(prog * freq) * amp
	rotation.x = sin(prog * rot_freq) * rot_amp
	rotation.y += 0.01
