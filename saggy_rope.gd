class_name SaggyLine extends Node3D

const FISHING_LINE = preload("res://Decoration/fishing_line.tscn")
@onready var rope_segment_holder: Node = $RopeSegmentHolder

@export_range(0.01,1,0.01) var resolution: float = 1
@export var end_node:Node3D
@export_range(0.00,1,0.01) var tension: float = 0

func calc():
	clear()
	if !end_node: return
	var curve = Curve3D.new()
	curve.add_point(global_position)
	#This in_param makes the handle go back to the origin with a y value of the tension
	var in_param:Vector3 = Vector3(
		-end_node.global_position.x+global_position.x,
		lerp(0.0, -end_node.global_position.y+global_position.y, tension),
		-end_node.global_position.z+global_position.z
	)
	curve.add_point(end_node.global_position, in_param)
	#$Node/Path3D.curve = curve
	var length:float = curve.get_baked_length()
	#Now I want to make a number of line segments equal to the length / resolution, floored to a min of 1
	var num_segments:int = max(1, ceilf(length/resolution))
	var segment_length = length/float(num_segments)
	var sprite_array:Array[Sprite3D] = []
	var seg_start:Vector3 = global_position
	for i in num_segments:
		var this_seg_pos:Vector3 = curve.sample_baked(i * segment_length)
		var sprite_seg:Sprite3D = create_line_sprite(seg_start, this_seg_pos)
		sprite_array.append(sprite_seg)
		seg_start = this_seg_pos
		if i == num_segments - 1:
			var last_seg:Sprite3D = create_line_sprite(seg_start, end_node.global_position)
			sprite_array.append(last_seg)	
	for sprite:Sprite3D in sprite_array:
		rope_segment_holder.add_child(sprite)

func clear():
	rope_segment_holder.queue_free()
	rope_segment_holder = Node.new()
	add_child(rope_segment_holder)

func create_line_sprite(from:Vector3, to:Vector3) -> Sprite3D:
	var line:Sprite3D =  FISHING_LINE.instantiate()
	line.scale.z = (from-to).length() * 100
	line.position = from
	if from == to: return line
	line.look_at_from_position(from,to)
	return line
