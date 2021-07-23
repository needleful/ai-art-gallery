extends DiaScreen

signal door_lock(locked)
signal lights(lights_on)

export(String) var door_name = "Door"
export(NodePath) var door_node
export(NodePath) var control_node
export(bool) var lights = true setget set_lights
export(String) var pin = ""

onready var door = get_node(door_node)
onready var control = get_node(control_node)

func _ready():
	if "door_name" in control:
		control.door_name = door_name
	if "locked" in control and "locked" in door:
		control.locked = door.locked
	if "lights" in control:
		control.lights = lights
	if "pin" in control:
		control.pin = pin

func emit_locked(l):
	emit_signal("door_lock", l)

func set_lights(l):
	lights = l
	emit_signal("lights", l)
