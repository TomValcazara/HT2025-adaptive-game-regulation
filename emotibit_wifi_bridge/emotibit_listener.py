import socket

UDP_IP = "0.0.0.0"
UDP_PORT = 12345

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))
sock.settimeout(1.0)

print("Listening for EmotiBit data...")

while True:
    try:
        data, addr = sock.recvfrom(4096)
        print(data)
    except socket.timeout:
        pass
