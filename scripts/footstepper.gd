extends Spatial

export(Array, AudioStream) var audio_sources

onready var area:Area = $Area
onready var player:AudioStreamPlayer3D = $AudioStreamPlayer3D

var raised = true

func _ready():
	player.stream = audio_sources[0]
	var _x = area.connect("body_exited", self, "raise_foot")
	_x = area.connect("body_entered", self, "play")

func raise_foot(_x):
	raised = true

func play(_x):
	if raised:
		raised = false
		var s = randi() % audio_sources.size()
		player.stream = audio_sources[s]
		player.stream_paused = false
		player.play()
		player.playing = true
