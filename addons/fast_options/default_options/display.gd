extends Object

signal ui_redraw

var theme:Theme = load("res://ui/game_theme.tres")

export (int, 8, 48) var text_size setget set_textsize, get_textsize
export (Color) var text_color setget set_text_color, get_text_color

func get_name():
	return "Display"

func get_textsize():
	return theme.default_font.size

func set_textsize(val):
	text_size = val
	theme.default_font.size = val
	emit_signal("ui_redraw")

func get_text_color()->Color:
	return theme.get_color("font_color", "Label")

func set_text_color(val:Color):
	text_color = val
	theme.set_color("font_color", "Label", val)
	theme.set_color("font_color", "Button", val)
	theme.set_color("font_color", "OptionButton", val)
	theme.set_color("font_color_fg", "Tabs", val)
	theme.set_color("font_color_fg", "TabContainer", val)
	emit_signal("ui_redraw")
