extends Control

var mouse_pos : Vector2

func _input(event):
	if event is InputEventMouseMotion:
		$cursorLayer/cursor.position = event.position.round()
		mouse_pos = event.position


func _on_Button_pressed():
	if $WindowDialog:
		$WindowDialog.popup()
