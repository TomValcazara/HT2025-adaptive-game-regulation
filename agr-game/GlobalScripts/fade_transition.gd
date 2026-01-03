extends CanvasLayer

@export var fade_time := 0.5
@onready var rect := $ColorRect

func _ready():
	# ALWAYS start invisible
	rect.modulate.a = 0.0


func fade_to_scene(scene_path: String):
	
	var rect := $ColorRect
	rect.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, fade_time)
	tween.tween_callback(func ():
		get_tree().change_scene_to_file(scene_path)
	)
	tween.tween_property(rect, "modulate:a", 0.0, fade_time)
