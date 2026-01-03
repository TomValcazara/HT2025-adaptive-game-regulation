extends Node2D
const NEXT_SCENE := preload("res://Scenes/ProfileSelectorScene.tscn")

func _ready() -> void:
	pass
	


func _on_button_mouse_entered() -> void:
	$ButtonNextScene.scale = Vector2(1.1,1.1)


func _on_button_mouse_exited() -> void:
	$ButtonNextScene.scale = Vector2(1.0,1.0)


func _on_button_button_up() -> void:
	$ButtonNextScene.disabled = true
	#get_tree().change_scene_to_packed(NEXT_SCENE)
	FadeTransition.fade_to_scene("res://Scenes/ProfileSelectorScene.tscn")
	print("Next Scene")
