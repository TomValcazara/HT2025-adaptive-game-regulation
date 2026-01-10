extends Node2D

var gameplayRules = {}
var TotalRoundTimer := 0
var GamePlayArray = []
var RoundCounter = 0
var selectedAnswer
var countCorrect := 0
var countWrong := 0

func _ready() -> void:
	
	$Options.modulate.a = 0.0
	
	#Sets The Challenge Audio Based on the Room Noise
	AudioManager.setGamePlayVolume(NoiseSensorBridge.RoomStatus)
	
	createGamePlay()
	
	
	
func state_machine(state):
	
	match state:
	
		"question":
			
			#instruction
			$Instruction.text = "[wave]LISTEN[/wave]"
			
			#Play Challenge Audio
			AudioManager.playGameplayAudio(GamePlayArray[RoundCounter]["correct_answer"][0],gameplayRules["audio_side"])
			
			state_machine("answer")
			
		"answer":
			
			$Instruction.text = "[wave]ANSWER[/wave]"
			
			#Create Bubbles to Answer
			var _positions = [Vector2(200,350), Vector2(580,460), Vector2(320,740), Vector2(880,700), Vector2(1000,340), Vector2(1300,720), Vector2(1480,340)]
			_positions.shuffle()
			var _count = 0
			for _nodes in $Options.get_children():
				_nodes.queue_free()
			for _color in GamePlayArray[RoundCounter]["options"]:
				var answerButton := preload("res://Artefacts/button_option.tscn").instantiate() 
				answerButton.position = _positions[_count]
				answerButton.funcChangeColor(_color)
				answerButton.button_up.connect(func():
					funcSelectedAnswer(_color, answerButton)
				)
				#Option Bubble Movement Speed/Intensity
				answerButton.bubble_movement_speed(gameplayRules["intensity_movement"])
				$Options.add_child(answerButton)
				
				_count += 1
			
			$Options.modulate.a = 0.0
			var tween := $Options.create_tween()
			tween.tween_property($Options, "modulate:a", 1.0, 0.5)
				
		"verify":
			
			if selectedAnswer == GamePlayArray[RoundCounter]["correct_answer"][0]:
				countCorrect += 1
				$HUD/HBoxContainer/HudCorrect/Label.text = str(countCorrect)
				$Instruction.text = "[wave]CORRECT[/wave]"
			else:
				countWrong += 1
				$HUD/HBoxContainer/HudWrong/Label.text = str(countWrong)
				$Instruction.text = "[wave]WRONG[/wave]"
			
			await get_tree().create_timer(1.0).timeout
			
			#Round 9 is the last round before finishing the game
			if RoundCounter < 9:
				RoundCounter += 1
				state_machine("question")
				
			else:
				state_machine("finish")

		
		"finish":
			
			$Instruction.text = "[wave]GAME OVER[/wave]"
			$HUD/HBoxContainer/HudTime/RoundTimer.stop()
			$Options.visible = false
			
			#Saves Player Score for the ScoreScreen
			GlobalManager.PlayerScore = {
				"time": $HUD/HBoxContainer/HudTime/Label.text,
				"correct_answer": int($HUD/HBoxContainer/HudCorrect/Label.text)
			}
			
			await get_tree().create_timer(1.0).timeout
			FadeTransition.fade_to_scene("res://Scenes/ScoreScreen.tscn")
			
func funcSelectedAnswer(_color, _button):
	
	#Blocks All Bubbles
	for _buttons in $Options.get_children():
		_buttons.disabled = true
	
	#Pops the button
	#_button.visible = false
	_button.funcChangeColor("poped")
	
	#Audio FX for Bubble
	AudioManager.playBubbleFX()
	
	#Saves selected Answer
	selectedAnswer = _color
	
	#Hide Bubbles
	var tween := $Options.create_tween()
	tween.tween_property($Options, "modulate:a", 0.0, 0.5)
		
	#Verifies answer
	state_machine("verify")
	

func createGamePlay() -> void:
	
	var _levelTier
	if GlobalManager.TestingMode == true:
		_levelTier = 9
	else:
		_levelTier = GlobalManager.GameDifficultyTier
	
	#For Testing Only
	if GlobalManager.CurrentProfile["name"] == "CHILL GUY":
		_levelTier = 9
	elif GlobalManager.CurrentProfile["name"] == "STRESSED GUY":
		_levelTier = 1
	
	match _levelTier:
		1:
			gameplayRules = { 
				"intensity_movement": 1,
				"number_colors": 2,
				"hud": "hidden",
				"ambient_music" : "off",
				"audio_side" : "dual",
				"background_animation": false
			}
		2:
			gameplayRules = { 
				"intensity_movement": 2,
				"number_colors": 2,
				"hud": "hidden",
				"ambient_music" : "off",
				"audio_side" : "dual",
				"background_animation": false
			}
		3:
			gameplayRules = { 
				"intensity_movement": 3,
				"number_colors": 2,
				"hud": "hidden",
				"ambient_music" : "off",
				"audio_side" : "dual",
				"background_animation": false
			}
		4:
			gameplayRules = { 
				"intensity_movement": 4,
				"number_colors": 3,
				"hud": "partial",
				"ambient_music" : "low",
				"audio_side" : "dual",
				"background_animation": true
			}
		5:
			gameplayRules = { 
				"intensity_movement": 5,
				"number_colors": 4,
				"hud": "partial",
				"ambient_music" : "low",
				"audio_side" : "dual",
				"background_animation": true
			}
		6:
			gameplayRules = { 
				"intensity_movement": 6,
				"number_colors": 5,
				"hud": "partial",
				"ambient_music" : "low",
				"audio_side" : "dual",
				"background_animation": true
			}
		7:
			gameplayRules = { 
				"intensity_movement": 7,
				"number_colors": 6,
				"hud": "full",
				"ambient_music" : "high",
				"audio_side" : "random",
				"background_animation": true
			}
		8:
			gameplayRules = { 
				"intensity_movement": 8,
				"number_colors": 7,
				"hud": "full",
				"ambient_music" : "high",
				"audio_side" : "random",
				"background_animation": true
			}
		9:
			gameplayRules = { 
				"intensity_movement": 9,
				"number_colors": 7,
				"hud": "full",
				"ambient_music" : "high",
				"audio_side" : "random",
				"background_animation": true
			}
	
	#HUD
	$HUD/HBoxContainer/HudTime/RoundTimer.wait_time = 1.0
	$HUD/HBoxContainer/HudTime/RoundTimer.start()
	match gameplayRules["hud"]:
		"hidden":
			$HUD.visible = false
		"partial":
			$HUD/HBoxContainer/HudCorrect.visible = false
			$HUD/HBoxContainer/HudWrong.visible = false
		"full":
			pass
			
	#Ambient Music
	AudioManager.setMusicVolume(gameplayRules["ambient_music"])
	
	#Background Animation
	$BackgroundAnimation.visible = gameplayRules["background_animation"]
	
	#GamePlayArray
	var _tempColor = ["purple","green","yellow","orange","pink","blue","red"]
	for _round in 10:
		var _currentround = {}
		_currentround["options"] = _tempColor.duplicate(true)
		_currentround["options"].shuffle()
		_currentround["options"].resize(gameplayRules["number_colors"])
		_currentround["correct_answer"] = _currentround["options"].duplicate(true)
		_currentround["correct_answer"].shuffle()
		_currentround["correct_answer"].resize(1)
		GamePlayArray.append(_currentround)
	#print(GamePlayArray)
	
	state_machine("question")
	
func _on_round_timer_timeout() -> void:
	
		TotalRoundTimer += 1
		$HUD/HBoxContainer/HudTime/Label.text = "%02d:%02d" % [TotalRoundTimer / 60, TotalRoundTimer % 60]
	
