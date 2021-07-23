extends Control
class_name MouseControlled

func _input(event):
	if event is InputEventMouseMotion:
		$cursorLayer/cursor.position = event.position.round()
