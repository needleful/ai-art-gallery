extends Control

signal exit

func hide_ui():
	$notes.visible = false
	$messages.visible = false

func _on_Messages_pressed():
	var v = $messages.visible
	hide_ui()
	if !v:
		$messages.visible = true

func _on_Notes_pressed():
	var v = $notes.visible
	hide_ui()
	if !v:
		$notes.visible = true

func _on_Files_pressed():
	pass # Replace with function body.

func on_exit():
	emit_signal("exit")

func _on_Exit_pressed():
	$logout_confirm.popup()
