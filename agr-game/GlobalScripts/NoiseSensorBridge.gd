extends Node2D

# ============================================================
# CONFIGURATION
# ============================================================

var pi_url: String = "http://192.168.2.2:8000/noise" # CHANGE IP IF NEEDED
var poll_interval := 1.0  # seconds

var noise_history := []

var RoomStatus := "analysing"

# ============================================================
# STATE
# ============================================================

var noise_detection: int = 0
var request_in_progress: bool = false

# ============================================================
# NODES (CREATED PROGRAMMATICALLY)
# ============================================================

var http: HTTPRequest
var timer: Timer

# ============================================================
# INITIALIZATION
# ============================================================

func _ready():
	# Create HTTPRequest node
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)

	# Create Timer node
	timer = Timer.new()
	timer.wait_time = poll_interval
	timer.autostart = true
	timer.timeout.connect(_request_noise_state)
	add_child(timer)

	print("NoiseSensorBridge initialized")

# ============================================================
# HTTP REQUEST LOGIC
# ============================================================

func _request_noise_state():
	# Prevent overlapping requests
	if request_in_progress:
		return

	request_in_progress = true
	var err := http.request(pi_url)

	if err != OK:
		request_in_progress = false
		print("HTTPRequest error:", err)

# ============================================================
# HTTP RESPONSE HANDLER
# ============================================================

func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
):
	# Always clear the busy flag first
	request_in_progress = false

	if result != HTTPRequest.RESULT_SUCCESS:
		print("HTTP failed:", result)
		return

	if response_code != 200:
		print("HTTP error code:", response_code)
		return

	var json_text := body.get_string_from_utf8().strip_edges()

	if json_text.is_empty():
		print("Empty response body")
		return

	var data: Variant = JSON.parse_string(json_text)

	if data == null:
		print("Invalid JSON:", json_text)
		return

	# Update state (keep previous value if key missing)
	noise_detection = int(data.get("noiseDetection", noise_detection))
	
	#Saves History of Noise
	if noise_detection == 0 or noise_detection == 1:
		noise_history.push_front(noise_detection)
		noise_history.resize(10)
	
	#Checks If room is Noise
	var _count_not_null = 0
	var _count_noise_detected = 0
	for _noise in noise_history:
		if _noise != null:
			_count_not_null += 1
		if _noise == 1:
			_count_noise_detected += 1
	if _count_not_null == 10: #has at least 10 readings of the room noise
		if _count_noise_detected >= 3:
			RoomStatus = "loud"
		else:
			RoomStatus = "quiet"
	else:
		RoomStatus = "analysing"
	
	
			
	# Debug (optional)
	LiveDebugDataWindow.get_node("Panel/LabelNoiseSensor").text = "Noise detection: "+str(noise_detection)
