extends KinematicBody

var locked = true

func _on_door_panel_pin_door_lock(p_locked):
	if locked == p_locked:
		return
	locked = p_locked
	if locked:
		print("Locked")
		$AnimationPlayer.play_backwards("open")
	else:
		print("Unlocked")
		$AnimationPlayer.play("open")
