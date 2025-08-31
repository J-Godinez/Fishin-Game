extends Node3D
const BLOCK = preload("res://Scenes/block.tscn")
@export var size:int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var x = -(size/2.0)
	var z = -(size/2.0)
	var y = 0
	for i in size:
		for j in size:
			add_block(x,y,z)
			if !(i != 0 && i != size-1) && !(j != 0 && j != size-1):
				for k in size-1:
					add_block(x,k+1,z)
			z += 1
		x += 1
		z = -(size/2.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_block(x,y,z):
	var block:StaticBody3D = BLOCK.instantiate()
	block.position.x = x
	block.position.y = y
	block.position.z = z
	add_child(block)
