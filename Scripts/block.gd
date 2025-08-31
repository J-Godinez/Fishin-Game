extends StaticBody3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
var mesh_material:StandardMaterial3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(mesh_material)
	mesh_material = mesh_instance_3d.get_surface_override_material(0)
	print(mesh_material)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	mesh_material.emission_enabled = true
	mesh_material.emission = Color.LAWN_GREEN


func _on_mouse_exited() -> void:
	mesh_material.emission_enabled = false
