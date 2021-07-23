extends Area

func _on_interactibles_wake_body_entered(body):
	if body is RigidBody:
		body.sleeping = false
		body.can_sleep = false

func _on_interactibles_wake_body_exited(body):
	if body is RigidBody:
		body.can_sleep = true
