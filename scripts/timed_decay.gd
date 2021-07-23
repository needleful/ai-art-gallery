extends Spatial

export(float) var time_to_live = 1

var t: Timer = Timer.new()

func _ready():
	add_child(t)
	t.start(time_to_live)
	var _x = t.connect("timeout", self, "on_timeout")

func on_timeout():
	queue_free()
