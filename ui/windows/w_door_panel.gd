extends MouseControlled

signal door_lock(locked)
signal lights(on)

export(String) var door_name = "Door" setget set_door_name
export(bool) var locked = false setget set_locked
export(bool) var lights = true setget set_lights
export(Color) var color_locked = Color.red
export(Color) var color_unlocked = Color.white
var pin: String setget set_pin

func set_door_name(n):
	door_name = n
	$box/name.text = n

func toggle_lock():
	set_locked(!locked)

func set_locked(l):
	locked = l
	if has_node("pin_pad"):
		if l:
			$pin_pad.approved_text = tr("Unlocked") 
		else:
			$pin_pad.approved_text = tr("Locked")
	if has_node("box/locked"):
		if l:
			$box/locked.text = tr("LOCKED")
			$box/locked["custom_colors/font_color"] = color_locked
			$box/Button.text = tr("UNLOCK")
		else:
			$box/locked.text = tr("UNLOCKED")
			$box/locked["custom_colors/font_color"] = color_unlocked
			$box/Button.text = tr("LOCK")
	emit_signal("door_lock", l)

func set_pin(p):
	pin = p
	if has_node("pin_pad"):
		$pin_pad.correct_pin = p

func _on_Button_pressed():
	set_locked(!locked)

func set_lights(l):
	lights = l
	if has_node("box/HBoxContainer/lights"):
		$box/HBoxContainer/lights.pressed = l

func _on_lights_toggled(button_pressed):
	lights = button_pressed
	emit_signal("lights", button_pressed)
