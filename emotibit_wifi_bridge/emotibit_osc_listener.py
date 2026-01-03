import time
import json
from collections import deque
from pythonosc import dispatcher
from pythonosc import osc_server
import threading

# ==============================
# CONFIGURATION
# ==============================

IP = "0.0.0.0"            # Listen on all network interfaces
PORT = 12345              # Same port used by EmotiBit OSC
OUTPUT_HZ = 1.0           # How often we output data (1 Hz = once per second)
WINDOW_SEC = 1.0           # How much data we buffer (1 second)
OUTPUT_FILE = "exported_data/emotibit_state.json"  # JSON file written for Godot

# ==============================
# DATA BUFFERS
# ==============================

# Each buffer stores tuples: (timestamp, value)
eda_buf = deque()
hr_buf = deque()          # REAL heart rate (BPM), sent by EmotiBit

# Signal quality flags
qual_eda = None
qual_hr = None

# Track last time we wrote JSON
last_emit = time.time()

# ==============================
# UTILITY FUNCTIONS
# ==============================

def now():
    """Return current time in seconds."""
    return time.time()

def prune(buffer):
    """
    Remove samples older than WINDOW_SEC.
    Keeps buffers small and time-bounded.
    """
    cutoff = now() - WINDOW_SEC
    while buffer and buffer[0][0] < cutoff:
        buffer.popleft()

def mean(buffer):
    """
    Compute the average value in a buffer.
    Returns None if buffer is empty.
    """
    return sum(v for _, v in buffer) / len(buffer) if buffer else None

# ==============================
# OSC HANDLERS
# ==============================

def handle_eda(address, *args):
    """
    Handle incoming EDA OSC messages.
    Multiple values may arrive per packet.
    """
    t = now()
    for v in args:
        eda_buf.append((t, float(v)))

def handle_hr(address, *args):
    """
    Handle incoming Heart Rate (BPM) OSC messages.
    This is already computed by EmotiBit (NOT raw PPG).
    """
    t = now()
    for v in args:
        hr_buf.append((t, float(v)))

def handle_quality(address, *args):
    """
    Handle signal quality messages.
    These may arrive rarely or not at all.
    """
    global qual_eda, qual_hr

    if "EDA:QUAL" in address and args:
        qual_eda = int(args[0])

    if "HR:QUAL" in address and args:
        qual_hr = int(args[0])

# ==============================
# OSC DISPATCHER SETUP
# ==============================

disp = dispatcher.Dispatcher()

# Map OSC addresses to handlers
disp.map("/EmotiBit/*/EDA", handle_eda)
disp.map("/EmotiBit/*/HR", handle_hr)
disp.map("/EmotiBit/*/EDA:QUAL", handle_quality)
disp.map("/EmotiBit/*/HR:QUAL", handle_quality)

# ==============================
# OSC SERVER
# ==============================

server = osc_server.ThreadingOSCUDPServer((IP, PORT), disp)
print("Listening for EmotiBit OSC data (EDA + HR)...")

# ==============================
# OUTPUT LOOP
# ==============================

def emit_loop():
    """
    Periodically aggregates buffered data
    and writes a clean JSON snapshot to disk.
    """
    global last_emit

    while True:
        time.sleep(0.01)  # Small sleep to avoid busy looping

        # Remove old samples
        prune(eda_buf)
        prune(hr_buf)

        # Check if it's time to output
        if now() - last_emit >= 1.0 / OUTPUT_HZ:
            payload = {
                "timestamp": round(now(), 3),

                # Aggregated physiological data
                "eda_mean": mean(eda_buf),
                "hr_bpm_mean": mean(hr_buf),

                # Signal quality (may be null)
                "signal_quality": {
                    "eda": qual_eda,
                    "hr": qual_hr,
                }
            }

            # Write JSON to file (overwrite)
            with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
                json.dump(payload, f, indent=2)

            # Optional console feedback
            print("Wrote JSON:", payload)

            last_emit = now()

# ==============================
# START EVERYTHING
# ==============================

# Run emit loop in background thread
threading.Thread(target=emit_loop, daemon=True).start()

# Start OSC server (blocking)
server.serve_forever()
