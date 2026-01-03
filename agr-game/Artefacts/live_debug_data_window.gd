extends CanvasLayer

func _ready() -> void:
	$Panel.visible = false
	$Panel2.visible = false
	$Panel3.visible = false
	
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		$Panel.visible = not $Panel.visible
		$Panel2.visible = not $Panel2.visible
		$Panel3.visible = not $Panel3.visible
