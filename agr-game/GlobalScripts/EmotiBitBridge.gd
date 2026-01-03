extends Node

# ==============================
# CONFIGURATION
# ==============================

# Path to the JSON file written by Python
# This path is relative to the project folder
#const JSON_PATH := "res://exported_data/emotibit_state.json"
const JSON_PATH := "C:/GIT/HT2025-adaptive-game-regulation/emotibit_wifi_bridge/exported_data/emotibit_state.json"

# How often (in seconds) Godot checks the file
# Should be >= Python output rate (you used 1 Hz)
const READ_INTERVAL := 1.0

# ==============================
# INTERNAL STATE
# ==============================

var _time_since_last_read := 0.0

# Last successfully read data
var emotibit_data: Dictionary = {}

var eda_history := []
var hr_history := []
var live_average_eda
var live_average_hr

# ==============================
# GODOT LIFECYCLE
# ==============================

func _process(delta: float) -> void:
	# Accumulate time since last read
	_time_since_last_read += delta

	# Only read the file every READ_INTERVAL seconds
	if _time_since_last_read >= READ_INTERVAL:
		_time_since_last_read = 0.0
		read_emotibit_json()

# ==============================
# JSON READING
# ==============================

func read_emotibit_json() -> void:
	# Check if the file exists before trying to read
	if not FileAccess.file_exists(JSON_PATH):
		print("EmotiBit JSON file not found:", JSON_PATH)
		return

	# Open the file in read mode
	var file := FileAccess.open(JSON_PATH, FileAccess.READ)

	# Safety check: file could not be opened
	if file == null:
		print("Failed to open EmotiBit JSON file")
		return

	# Read entire file as text
	var json_text := file.get_as_text()
	file.close()

	# Parse the JSON string
	var json := JSON.new()
	var parse_result := json.parse(json_text)

	# Check for parsing errors
	if parse_result != OK:
		print("JSON parse error:", json.get_error_message())
		return

	# Extract parsed data
	emotibit_data = json.get_data()
	
	#Creates a global copy of the last 10 entries
	save_data_history()
	
	
# ==============================
# DATA ACCESS / DEBUG
# ==============================

func save_data_history() -> void:
	
	# Safely extract fields with defaults (updated for HR, no PPG)
	var timestamp = emotibit_data.get("timestamp", null)
	var eda = emotibit_data.get("eda_mean", null)
	var hr = emotibit_data.get("hr_bpm_mean", null)
	var quality = emotibit_data.get("signal_quality", {})

	var _data_to_print := ""
	_data_to_print += "\n--- EMOTIBIT ---"
	_data_to_print += "\nTimestamp: " + str(timestamp)
	_data_to_print += "\nEDA mean: " + str(eda)
	_data_to_print += "\nHR (BPM): " + str(hr)
	_data_to_print += "\nSignal quality: " + str(quality)
	LiveDebugDataWindow.get_node("Panel/LabelEmotiBit").text = _data_to_print
	
	#Data to save / History of last 10 entries
	if quality["eda"] == null: #Safe to store
		if eda != null:
			eda_history.push_front(eda)
			eda_history.resize(10)
	if quality["hr"] == null: #Safe to store
		if hr != null:
			hr_history.push_front(hr)
			hr_history.resize(10)
		
func get_average_live_eda() -> float:
	
	var _average_eda = 0
	var _count = 0
	
	for _eda in eda_history:
		if _eda != null:
			_average_eda = _average_eda + _eda
	if _count > 0:
		_average_eda = _average_eda / _count
	LiveDebugDataWindow.get_node("Panel2/LastEDA").text = "Average EDA: "+str(_average_eda)
	
	return _average_eda
	
func get_average_live_hr() -> float:
	
	var _average_hr = 0
	var _count = 0
	
	for _hr in hr_history:
		if _hr != null:
			_average_hr = _average_hr + _hr
			_count += 1
	if _count > 0:
		_average_hr = _average_hr / _count
	LiveDebugDataWindow.get_node("Panel2/LastHR").text = "Average HR: "+str(_average_hr)
	
	return _average_hr
	
	
#var eda_history := []
#var hr_history := []
#var live_average_eda
#var live_average_hr
