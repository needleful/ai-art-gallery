extends Spatial

onready var anim : AnimationTree = $AnimationTree

var player: Spatial

func look(var weight : float):
	var w = anim["parameters/torso/blend_position"]
	anim["parameters/torso/blend_position"] = lerp(w, weight, 0.5)

func animate_movement(move:Vector2, crouch:float):
	anim["parameters/lower/blend_amount"] = crouch
	anim["parameters/walk/blend_position"] = move
	anim["parameters/crouch/blend_position"] = move
