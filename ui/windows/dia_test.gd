extends Control

var mouse_pos : Vector2

export(int, 1, 4) var page = 1 setget set_page

func _input(event):
	if event is InputEventMouseMotion:
		$cursorLayer/cursor.position = event.position.round()
		mouse_pos = event.position


func _on_Button_pressed():
	if $WindowDialog:
		$WindowDialog.popup()

func set_page(p):
	page = p
	if page < 1:
		page = 1
	if page > 4:
		page = 4
	if page == 1:
		$Panel/previous.disabled = true
	else:
		$Panel/previous.disabled = false
	if page == 4:
		$Panel/next.disabled = true
	else:
		$Panel/next.disabled = false
	
	$Panel/page1.visible = false
	$Panel/page2.visible = false
	$Panel/page3.visible = false
	$Panel/page4.visible = false
	get_node("Panel/page%d" % page).visible = true
			

func _on_previous_pressed():
	set_page(page-1)

func _on_next_pressed():
	set_page(page+1)
