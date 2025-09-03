extends RigidBody3D

class_name Bobber

#NOTE:
	# ✅ set_contact_monitor(true) to enable the emission of signals when it collides (specifically on instantiation i think, so in the player script)
	# ✅ on the signal _on_body_entered we might use get_colliding_bodies() to detect what the bobber collides with
	# ✅ if it collides with the water, and/or a fishing spot, we freeze it in place 
	#✅  to freeze it we must use set_freeze_enabled(true) after using set_freeze_mode(FREEZE_MODE_STATIC)
		#✅  new plan is to set both velocities to zero, so that it can be moved by the LakeCollisionArea itself
	# we should also probably enter a fishing state that ends when you reel in the bobber
	# begin a bobbing animation and set_contact_monitor(false) to turn off collision signals
	# if we hit a fishing spot, set a timer of some sort, at the end of which we enter a bite state
	# during that state, the bobber plummets under the water, and left clicking will add the fish to your inventory


func _on_body_entered(body: Node) -> void:
	if body.get_name() != "LakeCollisionArea":
		queue_free()
		return
	print(body.get_name())
	print("Linear Velocity", linear_velocity, "Angular Velocity", angular_velocity)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	#freeze_mode = Bobber.FREEZE_MODE_STATIC
	#freeze = true
