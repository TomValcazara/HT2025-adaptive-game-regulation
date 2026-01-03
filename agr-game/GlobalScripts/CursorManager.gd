extends Node

func _ready():
	Input.set_custom_mouse_cursor(
		preload("res://Assets/Images/cursor_arrow.png"),
		Input.CURSOR_ARROW,
		Vector2.ZERO
	)

	Input.set_custom_mouse_cursor(
		preload("res://Assets/Images/cursor_pointer.png"),
		Input.CURSOR_POINTING_HAND,
		Vector2.ZERO
	)

	Input.set_custom_mouse_cursor(
		preload("res://Assets/Images/cursor_forbidden.png"),
		Input.CURSOR_FORBIDDEN,
		Vector2.ZERO
	)
