extends Node
class_name ControlsOptions

export(bool) var toggle_crouch setget set_toggle_crouch, get_toggle_crouch
export(bool) var toggle_zoom setget set_toggle_zoom, get_toggle_zoom

onready var player = get_tree().current_scene.get_node("Player")

func get_name() -> String:
	return "Controls"

func set_toggle_crouch(t):
	toggle_crouch = t
	player.toggle_crouch = t

func get_toggle_crouch():
	if player:
		return player.toggle_crouch
	else:
		return toggle_crouch

func set_toggle_zoom(z):
	toggle_zoom = z
	player.toggle_zoom = z

func get_toggle_zoom():
	if player:
		return player.toggle_zoom
	else:
		return toggle_zoom
