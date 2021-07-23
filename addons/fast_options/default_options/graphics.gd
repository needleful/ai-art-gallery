extends Object
class_name GraphicsOptions

#warning-ignore:unused_class_variable
export(bool) var full_screen setget set_fullscreen, get_fullscreen
#warning-ignore:unused_class_variable
export(bool) var vsync setget set_vsync, get_vsync

func get_name() -> String:
	return "Graphics"

func set_fullscreen(val: bool):
	OS.window_fullscreen = val

func get_fullscreen() -> bool:
	return OS.window_fullscreen

func set_vsync(val: bool):
	OS.vsync_enabled = val

func get_vsync()->bool:
	return OS.vsync_enabled
