extends Area

func _on_jumpscare_body_entered(_body):
	$"../AnimationPlayer".play("scare")


func _on_jumpscare_body_exited(_body):
	$"../AnimationPlayer".play("reset")
