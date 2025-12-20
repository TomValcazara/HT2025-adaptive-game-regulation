import asyncio
from bleak import BleakClient

ADDRESSES = [
"EC:81:93:59:9E:94", 
"57:79:C2:67:10:98", 
"67:79:4F:5F:E8:32", 
"50:15:44:38:63:0E", 
"53:9F:C6:01:D9:46", 
"88:0E:85:03:BF:72", 
"D4:F8:92:D1:4B:0A"
]

async def main():
    for addr in ADDRESSES:
        print(f"Trying {addr}...")
        try:
            async with BleakClient(addr, timeout=5) as client:
                services = await client.get_services()
                print(f"\n✅ Connected to {addr}")
                for s in services:
                    print(s.uuid, s.description)
                return
        except Exception as e:
            print(f"❌ Failed: {addr}")

    print("\nNo device connected.")

asyncio.run(main())
