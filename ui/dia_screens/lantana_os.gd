extends Spatial

export(CharacterAccount) var user_account
export(NodePath) var screen_control

onready var screen = get_node(screen_control)

func _ready():
	if screen and screen.has_method("load_account"):
		screen.load_account(user_account)
