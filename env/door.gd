extends Spatial

export(bool) var locked setget set_locked

func set_locked(l):
	locked = l
	if locked:
		$lock["params/impulse_clamp"] = 0
	else:
		$lock["params/impulse_clamp"] = 0.001
