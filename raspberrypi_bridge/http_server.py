import RPi.GPIO as GPIO
import time
import json
from datetime import datetime, UTC
from http.server import BaseHTTPRequestHandler, HTTPServer
import threading
from threading import Lock

# ============================================================
# HARDWARE CONTEXT (TEMPORARY PROTOTYPE SETUP)
# ------------------------------------------------------------
# - Sound sensor powered at 5V
# - Digital output (DO) connected directly to GPIO
# - Raspberry Pi GPIO is 3.3V-only → NOT electrically ideal
#
# TODO (FINAL HARDWARE FIX):
# - Add voltage divider / logic level shifter on DO
# ============================================================

SOUND_PIN = 4  # GPIO4 (physical pin 7)
PORT = 8000

GPIO.setmode(GPIO.BCM)
GPIO.setup(SOUND_PIN, GPIO.IN)

# ============================================================
# SHARED STATE (ALWAYS VALID JSON)
# ============================================================

noise_state = {
    "timestamp": "init",
    "noiseDetection": 0
}

state_lock = Lock()

# ============================================================
# SENSOR SAMPLING THREAD
# ------------------------------------------------------------
# - 5 samples per second (every 0.2s)
# - One decision per second
# - If ANY sample is 1 → noiseDetection = 1
# ============================================================

def sensor_loop():
    global noise_state

    SAMPLES_PER_SECOND = 5
    SAMPLE_INTERVAL = 1.0 / SAMPLES_PER_SECOND

    while True:
        detected = 0

        for _ in range(SAMPLES_PER_SECOND):
            if GPIO.input(SOUND_PIN) == 1:
                detected = 1
            time.sleep(SAMPLE_INTERVAL)

        with state_lock:
            noise_state = {
                "timestamp": datetime.now(UTC).isoformat(),
                "noiseDetection": detected
            }

# ============================================================
# HTTP SERVER (Godot reads from here)
# ============================================================

class NoiseHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/noise":
            with state_lock:
                response = json.dumps(noise_state)

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(response)))
            self.end_headers()
            self.wfile.write(response.encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        return  # Disable default console logging

# ============================================================
# START THREADS
# ============================================================

try:
    threading.Thread(target=sensor_loop, daemon=True).start()

    server = HTTPServer(("0.0.0.0", PORT), NoiseHandler)
    print(f"Noise server running on port {PORT}")
    server.serve_forever()

except KeyboardInterrupt:
    print("\nStopping server")

finally:
    GPIO.cleanup()
