extends MouseControlled

var account : CharacterAccount
onready var access: Control = $access
var window: Control

var logged_in = false

func load_account(acc: CharacterAccount):
	account = acc
	$access/icon.texture = acc.avatar
	$access/humanName.text = "%s %s" % [acc.given_name, acc.family_name]
	$access/username.text = "@%s" % acc.username
	$access/pin_pad.correct_pin = acc.PIN
	if account.desktop_ui:
		window = account.desktop_ui.instance()
		window.connect("exit", self, "switch")

func _on_pin_approved():
	switch()

func switch():
	$AnimationPlayer.play("welcome")

func switch_screens():
	logged_in = !logged_in
	if logged_in:
		add_child_below_node(access, window)
		remove_child(access)
	else:
		add_child_below_node(window, access)
		remove_child(window)
		
