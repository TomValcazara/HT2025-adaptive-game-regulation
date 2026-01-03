extends Node2D

func _ready() -> void:
	
	AudioManager.ResumeMusic()
	
	var _user_score_text := ""
	_user_score_text += "\n [wave]CONGRATULATIONS[/wave]"
	_user_score_text += "\n"
	_user_score_text += "\n"
	_user_score_text += "\n [b]SCORE:[/b] "+str(GlobalManager.PlayerScore["correct_answer"]*10)
	_user_score_text += "\n [b]BURSTED BUBBLES:[/b] "+str(GlobalManager.PlayerScore["correct_answer"])
	_user_score_text += "\n [b]TOTAL TIME:[/b] "+str(GlobalManager.PlayerScore["time"])
	$MessageBox/WarningMessage.text = _user_score_text
	


func _on_button_menu_button_up() -> void:
	$HBoxContainer/ButtonMenu.disabled = true
	$HBoxContainer/ButtonPlayAgain.disabled = true
	FadeTransition.fade_to_scene("res://Scenes/ProfileSelectorScene.tscn")


func _on_button_play_again_button_up() -> void:
	$HBoxContainer/ButtonMenu.disabled = true
	$HBoxContainer/ButtonPlayAgain.disabled = true
	FadeTransition.fade_to_scene("res://Scenes/GamePlayTierEvaluation.tscn")
