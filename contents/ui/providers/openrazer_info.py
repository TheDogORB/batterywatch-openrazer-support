#!/usr/bin/env python3
"""
Helper script; prints connected Razer device info for RazerProvider.qml
Returns: JSON string 
Requires: openrazer-daemon (DKM) and the openrazer Python client library installed
"""
import json
import sys
 
def get_devices_json():
    try:
        from openrazer.client import DeviceManager
    except ImportError:
        print(json.dumps({"error": "openrazer client python library not found"}))
        sys.exit(1)

    try:
        dm = DeviceManager()
    except Exception as e:
        print(json.dumps({"error": f"Unable to connect to openrazer-daemon: {e}"}))
        sys.exit(1)
 
    devices = []
 
    for device in dm.devices:
        d = {
            "name": device.name,
            "serial": device.serial,
            "percentage": device.battery_level if device.has("battery") else -1,
            # "is_charging": device.is_charging if device.has("battery") else -1, # unused by widget, left out on purpose
            "type": device.type
        }

        devices.append(d)
 
    print(json.dumps(devices, indent=None))
 
 
if __name__ == "__main__":
    get_devices_json()
