extends RigidBody
class_name EntPlayer

export (float) var camera_fov_normal: float = 75.0
export (float) var camera_fov_zoomed: float = 45.0
export (bool) var toggle_zoom = true
export (bool) var toggle_grab = true
export (bool) var toggle_crouch = true
export (float) var sensitivity = 1.0

## Body parts
onready var torso: Spatial = $torso
onready var neck = torso.get_node("neck")
onready var head_target = neck.get_node("head_target")
onready var head: Spatial = head_target.get_node("head")
onready var cam: Camera = head.get_node("camera")
onready var uiCast: RayCast = head.get_node("uiCast") 
onready var itemCast: RayCast = head.get_node("itemCast")

## UI
onready var crosshair = $ui/crosshair

##Movement properties
enum State {
	Grounded,
	Air,
	Locked
}
const speed = 6
const jump_vel = 4

const accel_min = 0
const accel_max = 30
const accel_turn = 15
const deaccel = 20

const accel_max_air = 3
const accel_turn_air = 3
const deaccel_air = 3

var state = State.Grounded

## Crouching information
const FORCE_CROUCH_JUMP : float = 12000.0
var crouching: bool = false
var crouch_amount: float = 0.0
onready var pos_torso_standing: Vector3 = torso.translation
var pos_torso_crouching : Vector3 = Vector3(0, 0.8, 0)

## UI interaction
var ui_intersect:bool = false

##Camera 
enum CamState {
	Normal,
	Zoom
}

# How much of the camera's rotation is from the torso, from 0 to 1
const CAM_TORSO_RATIO = 0.5
const CAM_TORSO_NO_WEAPON = 0.0
const CAM_TORSO_ZOOMED_NOWEP = 0.2
const SNS_MOUSE:Vector2 = Vector2(1, 1)
const SNS_MOUSE_ZOOM: Vector2 = Vector2(0.4, 0.4)
const CAM_ROTATE_X = 250
var camState = CamState.Normal
var cam_zoom_amount = 0
var cam_angle:float = 0.0
var cam_mouse_movement: Vector2 = Vector2(0,0)
var old_mouse_movement: Vector2 = Vector2(0,0)

var previous_origin: Vector3
var real_velocity: Vector3 = Vector3(0,0,0)

const cam_speed_base = Vector3(1, 1, 1)
const cam_speed_shift = Vector3(.3, 0.3, .3)
const cam_span_base = Vector3(0.03, 0.05, .02) 
const cam_span_shift = Vector3(0.02, 0.03, .001)
const cam_span_factor = 0.05
const cam_span_zoomed = 0.02

var rnd_cam_speed : Vector3
var rnd_cam_span : Vector3
var rnd_cam_timer = Vector3(0,0,0)
# True if camera is parented to ironsights bone
# false if not
var sighted = false


## Physics interactions
# Force in newtons
const GRAB_MAX_FORCE = 700
# Force as a function of distance
const GRAB_FORCE_DIST = 40
const GRAB_DAMP_FACTOR = 10000
# Currently held object, or null if not grabbing
var held_object: RigidBody
# percentage of itemCast away from player
var grab_cast:float
# local offset on the item where to apply the forces
var grab_offset: Vector3

var grabbed_linear_damp
var grabbed_angular_damp

onready var animator : Spatial = $model

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animator.player = self
	previous_origin = global_transform.origin
	rnd_cam_span = cam_span_base
	rnd_cam_speed = cam_speed_base

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		var sns = sensitivity*lerp(SNS_MOUSE, SNS_MOUSE_ZOOM, cam_zoom_amount)
		cam_mouse_movement += event.relative*sns
	elif event.is_action("mv_crouch"):
		if event.is_action_pressed("mv_crouch"):
			if toggle_crouch:
				crouching = !crouching
			else:
				crouching = true
		elif !toggle_crouch:
			crouching = false
		$"col-crouching".disabled = !crouching
		$"col-standing".disabled = crouching
	elif event.is_action_pressed("cam_zoom"):
		if toggle_zoom:
			if camState == CamState.Zoom:
				camState = CamState.Normal
			else:
				camState = CamState.Zoom
		else:
			camState = CamState.Zoom
		get_tree().set_input_as_handled()
	elif !toggle_zoom and event.is_action_released("cam_zoom"):
		camState = CamState.Normal
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("phys_grab") or (
		event.is_action_pressed("wep_fire")
	):
		# Grab the object
		if held_object == null and itemCast.is_colliding():
			var i = itemCast.get_collider()
			if i is RigidBody:
				crosshair.get_node("ColorRect").color = Color.orange
				held_object = i
				
				grabbed_angular_damp = held_object.angular_damp
				grabbed_linear_damp = held_object.linear_damp
				held_object.angular_damp = GRAB_DAMP_FACTOR/(i.mass*i.mass + 1)
				held_object.linear_damp = 10/(abs(i.mass) + 1)
				var p = itemCast.get_collision_point()
				var dist = itemCast.cast_to.length()
				var cDist = (itemCast.global_transform.origin - p).length()
				grab_cast = cDist/dist
				grab_offset = i.global_transform.affine_inverse()*p
		elif toggle_grab and held_object:
			held_object.angular_damp = grabbed_angular_damp
			held_object.linear_damp = grabbed_linear_damp
			crosshair.get_node("ColorRect").color = Color.white
			held_object = null
	elif !toggle_grab and held_object and (
		event.is_action_released("phys_grab") or (
			event.is_action_released("wep_fire")
		)
	):
		held_object.angular_damp = grabbed_angular_damp
		held_object.linear_damp = grabbed_linear_damp
		crosshair.get_node("ColorRect").color = Color.white
		held_object = null

func _physics_process(delta) -> void:
	var direction: Vector2
	var x = Input.get_action_strength("mv_left") - Input.get_action_strength("mv_right")
	var y = Input.get_action_strength("mv_up") - Input.get_action_strength("mv_down")
	direction = Vector2(x, y)
	if direction.length_squared() > 1:
		direction = direction.normalized()
	match state:
		State.Air:
			if $floorArea.get_overlapping_bodies().size() > 0:
				state = State.Grounded
		State.Grounded:
			if Input.is_action_just_pressed("mv_jump"):
				var jump_force = jump_vel*mass
				if held_object:
					jump_force = clamp(jump_force - jump_vel*0.4*held_object.mass, 0, jump_force)
				apply_central_impulse(Vector3.UP*jump_force)
				state = State.Air
			if $floorArea.get_overlapping_bodies().size() == 0:
				state = State.Air
	
	#: apply input
	var lb: Vector3 = linear_velocity.slide(Vector3.UP).normalized()
	var b = global_transform.basis
	var input_dir = (b.x*direction.x + b.z*direction.y)
	
	var pos_delta = global_transform.origin - previous_origin
	previous_origin = global_transform.origin
	var v = pos_delta/delta
	real_velocity = real_velocity.linear_interpolate(v, 0.3)
	var vv = real_velocity.linear_interpolate(linear_velocity, 0.5)
	var vis_movement = Vector2(
		vv.dot(b.x),
		vv.dot(b.z)
	)/speed
	
	var old_crouch: float = crouch_amount
	if crouching or $headArea.get_overlapping_bodies().size() > 0:
		crouch_amount = lerp(crouch_amount, 1, 0.1)
		if crouch_amount > 0.8:
			$"col-standing".disabled = true
		if crouch_amount >= 0.99:
			crouch_amount = 1
	else:
		$"col-standing".disabled = crouching
		crouch_amount = lerp(crouch_amount, 0, 0.05)
		if crouch_amount <= 0.01:
			crouch_amount = 0
	
	animator.animate_movement(vis_movement, crouch_amount)
	
	var amax = accel_max
	var dec = deaccel
	var aturn = accel_turn
	
	if state == State.Air:
		amax = accel_max_air
		dec = deaccel_air
		aturn = accel_turn_air
		var crouch_delta = crouch_amount - old_crouch
		add_central_force(FORCE_CROUCH_JUMP*Vector3.UP*crouch_delta)
	
	var accel: float = accel_max
	var proj: Vector3 = input_dir
	var rej = Vector3.ZERO
	if lb != Vector3.ZERO:
		proj = input_dir.project(lb)
		rej = input_dir - proj
		if input_dir == Vector3.ZERO:
			var s = clamp(linear_velocity.length_squared()/(speed*speed), 0, 1)
			proj = -s*linear_velocity.normalized()
			accel = dec
		elif proj.dot(linear_velocity) < 0:
			proj = (input_dir - linear_velocity.slide(Vector3.UP)).normalized()
			accel = dec
		else:
			accel = lerp(amax, accel_min, linear_velocity.length_squared()/(speed*speed))
			accel = clamp(accel, accel_min, amax)
	elif state == State.Air:
		accel = accel_max_air
	var forceMass = mass
	if held_object:
		forceMass *= mass/(mass+held_object.mass)
	add_central_force((proj*accel + rej*aturn)*forceMass)
	torso.translation = lerp(pos_torso_standing, pos_torso_crouching, crouch_amount)
	## Object interaction
	if held_object:
		var target_pos: Vector3 = itemCast.global_transform*(grab_cast*itemCast.cast_to)
		var grab_pos = held_object.global_transform*grab_offset
		var grab_delta = target_pos - grab_pos
		
		var grab_force = clamp(
			grab_delta.length_squared()*GRAB_FORCE_DIST*held_object.mass*held_object.mass,
			0, GRAB_MAX_FORCE)
		held_object.add_force(grab_delta.normalized()*grab_force, grab_offset)
		
		var vel_delta = real_velocity - held_object.linear_velocity
		var vel_force = clamp(
			0.5*vel_delta.length_squared()*held_object.mass*held_object.mass,
			0, GRAB_MAX_FORCE)
		held_object.add_central_force(vel_force*vel_delta.normalized())
	elif itemCast.is_colliding():
		var i = itemCast.get_collider()
		if i is RigidBody:
			crosshair.visible = true
			$ui/art_panel.visible = false
			$ui/ref_crosshair.visible = false
		else:
			crosshair.visible = false
			if i.has_method("get_art_info"):
				var inf = i.get_art_info()
				$ui/art_panel.visible = true
				$ui/art_panel/vbox/Title.text = inf['title']
				$ui/art_panel/vbox/Medium.text = inf['medium']
				$ui/ref_crosshair.visible = false
			else:
				$ui/art_panel.visible = false
				$ui/ref_crosshair.visible = true
	else:
		crosshair.visible = false
		$ui/art_panel.visible = false
		$ui/ref_crosshair.visible = true
	
	if (ui_intersect or !sighted) and uiCast.is_colliding():
		$ui/ref_crosshair.visible = false
		var col = uiCast.get_collider()
		if col.has_method("process_mouse"):
			ui_intersect = true
			crosshair.visible = false
			var clicked = Input.is_action_just_pressed("gm_click")
			var released = Input.is_action_just_released("gm_click")
			col.process_mouse(uiCast.get_collision_point(), clicked, released)
		else:
			ui_intersect = false
	else:
		ui_intersect = false
	camera_look(delta)


func _process(delta) -> void:
	head.translation = Vector3.ZERO
	#Camera FOV
	if camState == CamState.Normal:
		var interp = min(delta*20, 1)
		cam_zoom_amount = lerp(cam_zoom_amount, 0, interp)
	elif camState == CamState.Zoom:
		var interp = min(delta*40, 1)
		cam_zoom_amount = lerp(cam_zoom_amount, 1, interp)
	
	cam.fov = lerp(camera_fov_normal, camera_fov_zoomed, cam_zoom_amount)
	
	head.global_transform.basis = head_target.global_transform.basis
	#Random head movement
	rnd_cam_timer += delta*rnd_cam_speed
	for i in range(3):
		if rnd_cam_timer[i] >= PI*2:
			rnd_cam_timer[i] = 0
			rnd_cam_span[i] = cam_span_base[i] + randf()*2*cam_span_shift[i]-cam_span_shift[i]
			rnd_cam_speed[i] = cam_speed_base[i] + randf()*2*cam_speed_shift[i]-cam_speed_shift[i]
	var f = lerp(cam_span_factor, cam_span_zoomed, cam_zoom_amount)
	head.translate(
		Vector3(
			sin(rnd_cam_timer.x)*rnd_cam_span.x, 
			sin(rnd_cam_timer.y)*rnd_cam_span.y, 
			sin(rnd_cam_timer.z)*rnd_cam_span.z) * f
		)

func camera_look(delta):
	# Camera look
	var movement = delta*(cam_mouse_movement + old_mouse_movement)/2
	old_mouse_movement = cam_mouse_movement
	cam_mouse_movement = Vector2(0,0)
	
	angular_velocity *= 0.1
	angular_velocity -= movement.x*transform.basis.y*CAM_ROTATE_X
	
	cam_angle = clamp(cam_angle + movement.y, -PI/2, PI/2)
	var t1: float
	var t2: float
	t1 = CAM_TORSO_NO_WEAPON
	t2 = CAM_TORSO_ZOOMED_NOWEP
	var torsoMove = lerp(t1, t2, cam_zoom_amount)

	torso.set_rotation(Vector3(cam_angle*torsoMove, 0, 0))
	neck.set_rotation(Vector3(cam_angle*(1-torsoMove), 0, 0))
	animator.look(-torsoMove*cam_angle*(2/PI))

func get_target():
	return torso.transform.origin

func die():
	print("ded")
	var _r = get_tree().reload_current_scene()
