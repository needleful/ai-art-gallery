extends Button

onready var pad = $"../../../"

func _ready():
	var _x = connect("pressed", self, "on_pressed")

func on_pressed():
	pad.number_press(text)
