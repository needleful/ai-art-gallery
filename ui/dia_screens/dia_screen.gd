# This script written with reference to the GUI in 3D script made by the Godot team
extends Spatial
class_name DiaScreen

const DEVICE_MAGIC = 301301

export(Vector2) var screen_size : Vector2 = Vector2(1,1)
export(NodePath) var quad_node = NodePath("./quad")
export(NodePath) var viewport_node = NodePath("./Viewport")

onready var quad: MeshInstance = get_node(quad_node)
onready var viewport: Viewport = get_node(viewport_node)

# Mouse position in screen space
onready var mouse_pos = viewport.size/2

func _ready():
	var smat: ShaderMaterial = quad.material_override
	smat.set_shader_param("viewport_size", viewport.size)

func _unhandled_input(event):
	if event is InputEventMouse:
		event.position = mouse_pos
		event.global_position = mouse_pos

func process_mouse(world_pos: Vector3, clicked: bool, released: bool):
	var local_pos : Vector3 = global_transform.affine_inverse() * world_pos
	var pos2d = Vector2(local_pos.x, -local_pos.y)
	
	pos2d = Vector2(
		pos2d.x + screen_size.x/2,
		pos2d.y + screen_size.y/2
	)*viewport.size/screen_size
	
	var moveEvent:InputEventMouseMotion = InputEventMouseMotion.new()
	
	moveEvent.relative = pos2d - mouse_pos
	moveEvent.global_position = pos2d
	moveEvent.position = pos2d
	moveEvent.device = DEVICE_MAGIC
	
	if clicked or released:
		moveEvent.button_mask = BUTTON_MASK_LEFT
		viewport.input(moveEvent)
		var clickEvent = InputEventMouseButton.new()
		clickEvent.position = pos2d
		clickEvent.global_position = pos2d
		clickEvent.pressed = clicked
		clickEvent.button_mask = BUTTON_MASK_LEFT
		clickEvent.button_index = BUTTON_LEFT
		clickEvent.device = DEVICE_MAGIC
		viewport.input(clickEvent)
	else:
		viewport.input(moveEvent)
	
	mouse_pos = pos2d
