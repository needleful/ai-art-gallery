extends Control

signal pin_failed
signal pin_approved

export var correct_pin : String
export(String) var default_text = tr("Enter PIN")
export(String) var approved_text = tr("Approved")
export(String) var failed_text = tr("Invalid PIN")
export(Color) var default_text_color = Color.white
export(Color) var approved_text_color = Color.greenyellow
export(Color) var failed_text_color = Color.crimson

var working_string : String = ""

onready var status:Label = $Panel/Text

func number_press(text):
	if working_string == "":
		working_string = text
		status.text = "*"
		status.add_color_override("font_color", default_text_color)
	else:
		working_string += text
		status.text += "*"

func cancel():
	status.add_color_override("font_color", default_text_color)
	working_string = ""
	status.text = default_text

func check():
	if working_string == correct_pin:
		status.text = approved_text
		status.add_color_override("font_color", approved_text_color)
		emit_signal("pin_approved")
	else:
		status.text = failed_text
		status.add_color_override("font_color", failed_text_color)
		emit_signal("pin_failed")
	working_string = ""
