extends Node2D

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

	# Optional: debug output
	debug_print_data()

# ==============================
# DATA ACCESS / DEBUG
# ==============================

func debug_print_data() -> void:
	# Safely extract fields with defaults
	var timestamp = emotibit_data.get("timestamp", null)
	var eda = emotibit_data.get("eda_mean", null)
	var ppg = emotibit_data.get("ppg_mean", {})
	var quality = emotibit_data.get("signal_quality", {})
	
	#print("--- EmotiBit Update ---")
	#print("Timestamp:", timestamp)
	#print("EDA mean:", eda)
	#print("PPG IR:", ppg.get("IR", null))
	#print("PPG RED:", ppg.get("RED", null))
	#print("PPG GRN:", ppg.get("GRN", null))
	#print("Signal quality:", quality)
	
	var _data_to_print = ""
	_data_to_print += "\n--- EmotiBit Update ---"
	_data_to_print += "\nTimestamp: "+str(timestamp)
	_data_to_print += "\nEDA mean: "+str(eda)
	_data_to_print += "\nPPG IR: "+str(ppg.get("IR", null))
	_data_to_print += "\nPPG RED: "+str(ppg.get("RED", null))
	_data_to_print += "\nPPG GRN: "+str(ppg.get("GRN", null))
	_data_to_print += "\nSignal quality: "+str(quality)
	print(_data_to_print)
	$RichTextLabel.text = _data_to_print
