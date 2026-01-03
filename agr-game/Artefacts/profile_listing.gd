extends VBoxContainer

var profile_id = 0

func _on_button_edit_button_up() -> void:
	print("Editing Profile: "+str(profile_id))
	
	GlobalManager.loadProfile(profile_id) #Loads Current Profile into the Global System
	FadeTransition.fade_to_scene("res://Scenes/ProfileEditorScene.tscn")

func _on_button_play_button_up() -> void:
	
	print("Play with Profile: "+str(profile_id))
	GlobalManager.loadProfile(profile_id) #Loads Current Profile into the Global System
	FadeTransition.fade_to_scene("res://Scenes/GamePlayTierEvaluation.tscn") #Game Tier Evaluation
