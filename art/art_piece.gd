tool
extends Spatial

export (Vector2) var art_scale := Vector2(1,1)
export (Texture) var art: Texture setget set_art
export (String) var title := ""
export (String) var medium := ""

func set_art(a):
	if has_node("MeshInstance"):
		art = a
		var s = art_scale*art.get_size()/Vector2(600, 600)
		$CollisionShape.shape.extents = Vector3(0.5*s.x, 0.5*s.y, 0.1)
		$MeshInstance.scale = Vector3(s.x, s.y, 1)
		$MeshInstance.get_surface_material(0).albedo_texture = art

func get_art_info():
	return {
		"title":title,
		"medium":medium
	}
