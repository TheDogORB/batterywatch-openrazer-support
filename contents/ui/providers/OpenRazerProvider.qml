import QtQuick 2.15
import org.kde.plasma.plasma5support 2.0 as P5Support
import "../DeviceUtils.js" as DeviceUtils

// Razer device provider
// Based on UPowerProvider.qml
// Author: TheDogORB

Item {
    id: root
    visible: false

    readonly property int deviceScanInterval: 5000          // How often getDevices is called

    // Helper getDevices var
    readonly property string getDeviceListCmd: "qdbus org.razer /org/razer razer.devices.getDevices"

    // Can't test this as I don't have means to connect mouse to PC via Bluetooth
    // but based on what I found on the openrazer github, Bluetooth is currently
    // unsupported, and devices connected via this mean are handled by kernel/OS
    // https://github.com/openrazer/openrazer/issues?q=state%3Aopen%20label%3ABluetooth

    // 0 = wired; 1 = wireless (dongle); 2 = bluetooth
    readonly property int wirelessType: 1

    // Data passed to the applet
    property var devices: []

    property var deviceData: ({})
    property var knownDevices: ({})

    // ═══════════════════════════════════════════════════════════════════════
    // GUI RELATED FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    // Refresh via "refresh" button in the GUI
    function refresh() {
        listSource.disconnectSource(getDeviceListCmd);
        listSource.connectSource(getDeviceListCmd);

        for (var id in deviceData) {
            fetchPowerInfo(id);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    // Updates the device model from the current internal state
    function updateOpenRazerDevices() {
        var result = [];

        for (var id in deviceData) {
            var d = deviceData[id];

            // Filter out devices w/o a battery or disconnected devices
            //
            // When device gets DCed but its dongle is still connected, name,
            // type vars still persists but battery charge (and firmware version)
            // is set to 0 (and v0.0 respectively) when device is powered off
            //
            // openrazer can report battery being 100% charged up to 30s after
            // connecting a device
            if (typeof d.battery !== "number" || d.battery <= 0)
                continue;
            result.push({
                name: d.name || i18n("Unknown Razer Device"),
                serial: id,
                percentage: d.battery,
                type: d.type || "unknown",
                icon: DeviceUtils.getIconForType(d.type || "unknown"),
                connectionType: wirelessType,
                source: "openrazer",
                batteries: [],
                charging: d.charging === true
            });
        }

        // Sorts devices alphabetically
        result.sort((a, b) => (a.name || "").localeCompare(b.name || ""));
        devices = result;
    }

    function fetchNameAndType(id) {
        detailsSource.connectSource(`qdbus org.razer /org/razer/device/${id} razer.device.misc.getDeviceName`);
        detailsSource.connectSource(`qdbus org.razer /org/razer/device/${id} razer.device.misc.getDeviceType`);
    }

    function fetchPowerInfo(id) {
        if (!deviceData[id])
            return;
        batterySource.connectSource(`qdbus org.razer /org/razer/device/${id} razer.device.power.getBattery`);
        chargingSource.connectSource(`qdbus org.razer /org/razer/device/${id} razer.device.power.isCharging`);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // DEVICE DISCOVERY
    // ═══════════════════════════════════════════════════════════════════════

    // openrazer lacks device added/removed signal -> instead devices are polled
    // periodically razer.devices.getDevices function
    // Result is then diffed against list of devices known in the last run of the
    // function -> new/disconnected devices are found
    P5Support.DataSource {
        id: listSource
        engine: "executable"
        interval: 0

        onNewData: (src, data) => {
            disconnectSource(src);

            var ids = data.stdout.split("\n").map(s => s.trim()).filter(Boolean);

            var current = {};

            ids.forEach(id => {
                current[id] = true;

                if (!knownDevices[id]) {
                    deviceData[id] = {
                        name: "",
                        type: "",
                        battery: undefined,
                        charging: false
                    };

                    fetchNameAndType(id);
                    fetchPowerInfo(id);
                }
            });

            // Remove unresponsive/stale devices
            for (var id in knownDevices) {
                if (!current[id]) {
                    delete deviceData[id];
                }
            }

            knownDevices = current;
            updateOpenRazerDevices();
        }

        Component.onCompleted: connectSource(getDeviceListCmd)
    }

    // ═══════════════════════════════════════════════════════════════════════
    // BATTERY HANDLING
    // ═══════════════════════════════════════════════════════════════════════

    // Updates percentage (battery charge) values via razer.device.power.getBattery
    // if the func exists for a device -> func doesn't exist for wired devices
    // if 0 = device with battery with no connection
    P5Support.DataSource {
        id: batterySource
        engine: "executable"
        interval: 0

        onNewData: (src, data) => {
            disconnectSource(src);

            if (!src.includes("/device/"))
                return;
            var id = src.split("/device/")[1].split(" ")[0];
            if (!deviceData[id])
                return;

            // Non-battery device
            if (data.stderr && data.stderr.includes("UnknownMethod")) {
                delete deviceData[id];
                updateOpenRazerDevices();
                return;
            }

            // 0 is handled in updateOpenRazerDevices()
            var raw = parseFloat(data.stdout);
            if (isNaN(raw))
                return;
            deviceData[id].battery = Math.round(Math.max(0, Math.min(100, raw)));

            updateOpenRazerDevices();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CHARGING HANDLING
    // ═══════════════════════════════════════════════════════════════════════

    P5Support.DataSource {
        id: chargingSource
        engine: "executable"
        interval: 0

        onNewData: (src, data) => {
            disconnectSource(src);

            if (!src.includes("/device/"))
                return;
            var id = src.split("/device/")[1].split(" ")[0];
            if (!deviceData[id])
                return;

            if (data.stderr && data.stderr.length > 0)
                return;
            deviceData[id].charging = data.stdout.trim() === "true";

            updateOpenRazerDevices();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // META DATA
    // ═══════════════════════════════════════════════════════════════════════

    P5Support.DataSource {
        id: detailsSource
        engine: "executable"
        interval: 0

        onNewData: (src, data) => {
            disconnectSource(src);

            if (!src.includes("/device/"))
                return;
            var id = src.split("/device/")[1].split(" ")[0];
            if (!deviceData[id])
                return;
            if (src.endsWith("getDeviceName")) {
                deviceData[id].name = data.stdout.trim();
            } else if (src.endsWith("getDeviceType")) {
                deviceData[id].type = data.stdout.trim();
            }

            updateOpenRazerDevices();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // TIMERS
    // ═══════════════════════════════════════════════════════════════════════

    // Periodic 'device discovery' scan + battery refresh
    Timer {
        interval: deviceScanInterval
        running: true
        repeat: true
        onTriggered: {
            refresh();
        }
    }
}
