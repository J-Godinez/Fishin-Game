extends Node3D

const BLOCK = preload("res://Scenes/block.tscn")
@export var size:int = 10
@onready var cactus: MultiMeshInstance3D = $Cactus
const CACTUS_ZONE = preload("res://Decoration/cactus_zone.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in cactus.multimesh.instance_count:
		var cactus_transform = cactus.multimesh.get_instance_transform(i)
		var static_body = CACTUS_ZONE.instantiate()
		static_body.transform = cactus_transform
		add_child(static_body)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_block(x,y,z):
	var block:StaticBody3D = BLOCK.instantiate()
	block.position.x = x
	block.position.y = y
	block.position.z = z
	add_child(block)
	
func draw_blocks(s):
	var x = -(s/2.0)
	var z = -(s/2.0)
	var y = 0
	for i in s:
		for j in s:
			add_block(x,y,z)
			if !(i != 0 && i != s-1) && !(j != 0 && j != s-1):
				for k in s-1:
					add_block(x,k+1,z)
			z += 1
		x += 1
		z = -(s/2.0)
