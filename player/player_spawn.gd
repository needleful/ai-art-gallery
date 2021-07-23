extends Spatial
class_name PlayerSpawn

func _ready():
	$"/root/Player".global_transform = global_transform
