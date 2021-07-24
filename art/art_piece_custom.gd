extends Node

export (String) var title := ""
export (String) var medium := ""

func get_art_info():
	return {
		"title":title,
		"medium":medium
	}
