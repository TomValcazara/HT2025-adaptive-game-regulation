extends Node

var CurrentProfile = {}
var GameDifficultyTier = 5
var TestingMode = true
var PlayerScore = {}

func _ready() -> void:
	resetProfile()
	
func resetProfile():
	CurrentProfile = {}
	
func loadProfile(_id):
	
	var profiles := []
	var dir := DirAccess.open("user://profiles")
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var file := FileAccess.open("user://profiles/" + file_name, FileAccess.READ)
			var current_profile = JSON.parse_string(file.get_as_text())
			if current_profile.id == _id:
				CurrentProfile = current_profile
				CurrentProfile["id"] = int(CurrentProfile["id"]) #JSON reading was converting Int values into Floats
			file.close()
		file_name = dir.get_next()
	dir.list_dir_end()
	pass
	
func get_average_baseline_eda() -> Dictionary:
	
	#Relaxed
	var _average_relaxed_eda = 0.0
	var _cont_relaxed = 0
	#Neutral
	var _average_neutral_eda = 0.0
	var _cont_neutral = 0
	#Tense
	var _average_tense_eda = 0.0
	var _cont_tense = 0
	
	for _value in CurrentProfile["emotibit_reading"]:
		if _value["classification"] == "relaxed":
			_cont_relaxed =+1
			_average_relaxed_eda = _average_relaxed_eda + _value["eda_reading_value"]
		if _value["classification"] == "neutral":
			_cont_neutral =+1
			_average_neutral_eda = _average_neutral_eda + _value["eda_reading_value"]
		if _value["classification"] == "tense":
			_cont_tense =+1
			_average_tense_eda = _average_tense_eda + _value["eda_reading_value"]
			
	if _cont_relaxed > 0:
		_average_relaxed_eda = _average_relaxed_eda / _cont_relaxed
	if _cont_neutral > 0:
		_average_neutral_eda = _average_neutral_eda / _cont_neutral
	if _cont_tense > 0:
		_average_tense_eda = _average_tense_eda / _cont_tense
	
	var final_baselines_from_profile = validate_eda_baselines(_average_relaxed_eda,_average_neutral_eda,_average_tense_eda)
	return final_baselines_from_profile
	
func get_average_baseline_hr() -> Dictionary:
	
	# Returns fixed baseline Heart Rate (HR) reference values.
	# These are NOT personalized and are used as common-sense
	# physiological guidelines for resting conditions.
	#
	# They are intentionally approximate and non-diagnostic.
	#
	# relaxed → lower arousal
	# neutral → typical resting state
	# tense   → elevated arousal
	
	return {
		"relaxed": 65,   # bpm — relaxed resting state
		"neutral": 75,   # bpm — typical resting baseline
		"tense": 90      # bpm — elevated arousal / tension
	}
	
func validate_eda_baselines(_average_relaxed_eda: float,_average_neutral_eda: float,_average_tense_eda: float) -> Dictionary:

	# Returns a Dictionary with consistent baseline values for:
	# relaxed < neutral < tense
	#
	# Rules:
	# - Any value == 0.0 means "missing"
	# - Neutral is the anchor when available
	# - Relaxed = 90% of neutral
	# - Tense   = 110% of neutral
	# - If provided values break ordering, they are ignored
	
	var relaxed := _average_relaxed_eda
	var neutral := _average_neutral_eda
	var tense := _average_tense_eda

	# --------------------------------------------------
	# 1) Choose a base anchor (prefer Neutral)
	# --------------------------------------------------
	var base: float

	if neutral > 0.0:
		base = neutral
	elif relaxed > 0.0:
		base = relaxed / 0.9        # infer neutral from relaxed
	elif tense > 0.0:
		base = tense / 1.1          # infer neutral from tense
	else:
		base = 0.0                  # should never happen, because the user has at least one mandatory reading when creating its Profile

	neutral = base

	# --------------------------------------------------
	# 2) Fill missing values using ±10%
	# --------------------------------------------------
	if relaxed == 0.0:
		relaxed = neutral * 0.9

	if tense == 0.0:
		tense = neutral * 1.1

	# --------------------------------------------------
	# 3) Validate ordering
	#    relaxed < neutral < tense
	#    If invalid, rebuild from neutral
	# --------------------------------------------------
	if not (relaxed < neutral and neutral < tense):
		relaxed = neutral * 0.9
		tense = neutral * 1.1

	# --------------------------------------------------
	# 4) Final guaranteed baselines
	# --------------------------------------------------
	return {
		"relaxed": relaxed,
		"neutral": neutral,
		"tense": tense
	}
	
		
