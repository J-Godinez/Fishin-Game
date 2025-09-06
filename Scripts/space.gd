extends Node3D

@export var fish_limit:int = 5
@export var spawn_delay:float = 10.0
@export var spawn_area_scalar:float = 0.5
@export var x_offset:float = 5.0
@export var z_offset:float = 5.0
@onready var cactus: MultiMeshInstance3D = $Cactus
@onready var timer: Timer = $Timer
@onready var lake_poly: CollisionPolygon3D = $LakeCollisionArea/CollisionPolygon3D
const BLOCK = preload("res://Scenes/block.tscn")
const CACTUS_ZONE = preload("res://Decoration/cactus_zone.tscn")
const FISH_ZONE = preload("res://Scenes/fish.tscn")
var fish_count:int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in cactus.multimesh.instance_count:
		var cactus_transform = cactus.multimesh.get_instance_transform(i)
		var static_body = CACTUS_ZONE.instantiate()
		static_body.transform = cactus_transform
		cactus.add_child(static_body)
		timer.start()
	get_lake_area()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func add_block(x,y,z):
	var block:StaticBody3D = BLOCK.instantiate()
	block.position.x = x
	block.position.y = y
	block.position.z = z
	add_child(block)
	
#func draw_blocks(s):
	#var x = -(s/2.0)
	#var z = -(s/2.0)
	#var y = 0
	#for i in s:
		#for j in s:
			#add_block(x,y,z)
			#if !(i != 0 && i != s-1) && !(j != 0 && j != s-1):
				#for k in s-1:
					#add_block(x,k+1,z)
			#z += 1
		#x += 1
		#z = -(s/2.0)


func _on_timer_timeout() -> void:
	spawn_fish()
	

func spawn_fish():
	if fish_count < fish_limit:
		pass
	pass


func get_lake_area():
	var lake_area: PackedVector2Array
	var v: Vector2
	#skip 22-25, those are for the dock. the array starts at 0 so this is already accounted for in the loop.
	#if we can't remove those indices simultaneously we should hypothetically be able to remove "22" 4 times, since the values would shift over
	for i in lake_poly.polygon.size():
		v = lake_poly.polygon.get(i)
		v.x = (v.x * spawn_area_scalar) - x_offset
		v.y = (v.y * spawn_area_scalar) + z_offset
		lake_area.append(v)
		add_block(v.x, 3, v.y)
	#print(lake_area)
