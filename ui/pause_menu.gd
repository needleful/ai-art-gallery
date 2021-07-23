extends Control

var previous_mouse_hold = null

func _input(event):
	if event.is_action_pressed("gm_pause"):
		pause(!get_tree().paused)
		get_tree().set_input_as_handled()

func _ready():
	pause(get_tree().paused)

func pause(pause):
	if pause:
		previous_mouse_hold = Input.get_mouse_mode()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif previous_mouse_hold != null:
		Input.set_mouse_mode(previous_mouse_hold)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = pause
	visible = pause

func _on_resume_pressed():
	pause(false)

func _on_exit_pressed():
	get_tree().quit()

func _on_options_pressed():
	$FastOptionsMenu.show()

func hide_options():
	$FastOptionsMenu.hide()
