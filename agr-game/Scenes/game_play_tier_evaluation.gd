extends Node2D

var time_left_onreading 

func _ready() -> void:

	#Disables Start Button
	$ButtonStartPlaying.disabled = true

	#Resets Timer
	if GlobalManager.TestingMode == true:
		time_left_onreading = 2 #For Testing Only
		$Timer/Label.text = "2 Seconds"
	else:
		time_left_onreading = 10
		$Timer/Label.text = "10 Seconds"
	
	
	$ButtonStartPlaying/TimerofReading.wait_time = 1.0
	$ButtonStartPlaying/TimerofReading.start()

	#Default Warning
	$MessageBox/WarningMessage.text = "Creating custom level.\nPlease wait."



func _on_button_start_playing_button_up() -> void:
	$ButtonStartPlaying.disabled = true
	FadeTransition.fade_to_scene("res://Scenes/GamePlayScene.tscn")


func _on_timerof_reading_timeout() -> void:
	
	#print("Every Second")
	time_left_onreading -= 1
	
	if time_left_onreading > 1:
		$Timer/Label.text = str(time_left_onreading)+" Seconds"
	elif time_left_onreading == 1:
		$Timer/Label.text = str(time_left_onreading)+" Second"
	elif time_left_onreading == 0:
		$Timer/Label.text = "Finished"
	elif time_left_onreading < 0:	
		$ButtonStartPlaying/TimerofReading.stop()
		funcSetsGameDifficultyTier()
		

func funcSetsGameDifficultyTier() -> void:
	
	#Get the working values	
	var _average_live_eda = EmotiBitBridge.get_average_live_eda() #Single float value with the average from the last 10 readings from the user
	var _average_live_hr = EmotiBitBridge.get_average_live_hr() #Single float value with the average from the last 10 readings from the user
	var _average_baseline_eda = GlobalManager.get_average_baseline_eda() #Dictionary with average value for relaxed/neutral/tense (Calculated based on the Profile readings)
	var _average_baseline_hr = GlobalManager.get_average_baseline_hr() #Dictionary with average value for relaxed/neutral/tense (Calculated using standard values)
	
	GlobalManager.GameDifficultyTier = calculate_level_tier(_average_live_eda,_average_live_hr,_average_baseline_eda,_average_baseline_hr)
	
	$ButtonStartPlaying.disabled = false
	$MessageBox/WarningMessage.text = "Game Ready to Play"
		

# Determines the adaptive difficulty tier (1–9)
# using MIDPOINT-BASED classification for EDA and HR.
#
# Rationale:
# - Physiological states are continuous
# - A user can be closer to "tense" before reaching the average tense value
# - We classify by ranges using midpoints between baselines
#
func calculate_level_tier( _average_live_eda: float, _average_live_hr: float, _average_baseline_eda: Dictionary, _average_baseline_hr: Dictionary) -> int:

	# --------------------------------------------------
	# 1) Compute EDA midpoints
	# --------------------------------------------------
	var eda_mid_relaxed_neutral := (
		float(_average_baseline_eda["relaxed"]) + float(_average_baseline_eda["neutral"])
	) / 2.0

	var eda_mid_neutral_tense := (
		float(_average_baseline_eda["neutral"]) + float(_average_baseline_eda["tense"])
	) / 2.0

	# --------------------------------------------------
	# 2) Classify EDA state using ranges
	# --------------------------------------------------
	var eda_state := "neutral"

	if _average_live_eda < eda_mid_relaxed_neutral:
		eda_state = "relaxed"
	elif _average_live_eda > eda_mid_neutral_tense:
		eda_state = "tense"

	# --------------------------------------------------
	# 3) Compute HR midpoints
	# --------------------------------------------------
	var hr_mid_relaxed_neutral := (
		float(_average_baseline_hr["relaxed"]) + float(_average_baseline_hr["neutral"])
	) / 2.0

	var hr_mid_neutral_tense := (
		float(_average_baseline_hr["neutral"]) + float(_average_baseline_hr["tense"])
	) / 2.0

	# --------------------------------------------------
	# 4) Classify HR state using ranges
	# --------------------------------------------------
	var hr_state := "neutral"

	if _average_live_hr < hr_mid_relaxed_neutral:
		hr_state = "relaxed"
	elif _average_live_hr > hr_mid_neutral_tense:
		hr_state = "tense"

	# --------------------------------------------------
	# 5) Map EDA + HR states to difficulty tier
	# --------------------------------------------------
	var tier_map := {
		"tense": {
			"tense": 1,
			"neutral": 2,
			"relaxed": 3
		},
		"neutral": {
			"tense": 4,
			"neutral": 5,
			"relaxed": 6
		},
		"relaxed": {
			"tense": 7,
			"neutral": 8,
			"relaxed": 9
		}
	}
	
	var _data_to_print = ""
	_data_to_print += "\nDifficulty Tier: "+str(tier_map[eda_state][hr_state])
	_data_to_print += "\nEDA Status: "+str(eda_state)
	_data_to_print += "\nHR Status: "+str(hr_state)
	LiveDebugDataWindow.get_node("Panel3/LabelEmotiBit").text = _data_to_print
	
	return tier_map[eda_state][hr_state]
	
