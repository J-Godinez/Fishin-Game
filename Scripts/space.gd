extends Node3D

@export var fish_limit:int = 5
@export var spawn_delay:float = 10.0
@export var spawn_area_scalar:float = 0.5
@export var spawn_range:float = 5.0
@onready var cactus: MultiMeshInstance3D = $Cactus
@onready var timer: Timer = $Timer
@onready var lake_poly: CollisionPolygon3D = $LakeCollisionArea/CollisionPolygon3D
@onready var lake_center: Marker3D = $Lake_Center

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
	get_tree().reload_current_scene()
	
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
	var lake_x = lake_center.position.x
	var lake_y = lake_center.position.y
	var lake_z = lake_center.position.z
	#for i in spawn_range:
		#add_block(lake_x + i, lake_y, lake_z + spawn_range - i - 1)
		#add_block(lake_x - i, lake_y, lake_z + spawn_range - i - 1)
		#add_block(lake_x + i, lake_y, lake_z - spawn_range + i + 1)
		#add_block(lake_x - i, lake_y, lake_z - spawn_range + i + 1)
		#add_block(lake_x + spawn_range - (2 * i), lake_y, lake_z + spawn_range)
		#add_block(lake_x + spawn_range, lake_y, lake_z + spawn_range - (2 * i))
		#
	#for j in 5:
		#add_block(lake_x, lake_y + j, lake_z)
