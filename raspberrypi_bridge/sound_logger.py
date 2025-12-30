import RPi.GPIO as GPIO
import time
import json
from datetime import datetime, UTC

# ============================================================
# TEMPORARY HARDWARE CONTEXT
# ------------------------------------------------------------
# - Sensor powered at 5V
# - DO connected directly to GPIO (no level shifting yet)
# - GPIO reads are binary (0 / 1)
#
# TODO (FINAL SETUP):
# - Add voltage divider / level shifter on DO
# ============================================================

SOUND_PIN = 4          # GPIO4 (physical pin 7)
LOG_FILE = "noise_state.json"

GPIO.setmode(GPIO.BCM)
GPIO.setup(SOUND_PIN, GPIO.IN)

# ============================================================
# SAMPLING CONFIGURATION
# ------------------------------------------------------------
# - 5 samples per second
# - One final decision per second
# - If ANY sample detects noise → noiseDetection = 1
# ============================================================

SAMPLES_PER_SECOND = 5
SAMPLE_INTERVAL = 1.0 / SAMPLES_PER_SECOND  # 0.2 seconds

print("Publishing noise state once per second (CTRL+C to stop)")
print("Sampling GPIO every 0.2 seconds")

try:
    while True:
        noise_detected = 0

        # Take multiple samples within one second
        for _ in range(SAMPLES_PER_SECOND):
            value = GPIO.input(SOUND_PIN)

            if value == 1:
                noise_detected = 1

            time.sleep(SAMPLE_INTERVAL)

        # Create output event (one per second)
        event = {
            "timestamp": datetime.now(UTC).isoformat(),
            "noiseDetection": noise_detected
        }

        # Overwrite JSON file with latest state
        with open(LOG_FILE, "w") as f:
            json.dump(event, f)

        print(event)

except KeyboardInterrupt:
    print("\nStopped by user")

finally:
    GPIO.cleanup()
