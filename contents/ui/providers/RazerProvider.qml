import QtQuick 2.15
import org.kde.plasma.plasma5support 2.0 as P5Support
import "../DeviceUtils.js" as DeviceUtils

// Razer device provider requires python-openrazer, and razer_info.py helper script to run
// Based on UpowerProvider.qml
Item {
    id: root
    visible: false
    // Controls how often device info gets fetched
    readonly property int refreshInterval: 60000

    property var devices: []

    // Path to helper script
    readonly property string helperScript: Qt.resolvedUrl("razer_info.py").toString().replace("file://", "")

    function refresh() {
        dataSource.connectSource("python3 " + helperScript)
    }

    // Parse .JSON output from the helper script to device variable
    function parseRazerOutput(stdout) {
        var parsed

        try {
            parsed = JSON.parse(stdout)
        } catch (e) {
            console.warn("RazerProvider: failed to parse JSON:", e, stdout)
            return []
        }

        if (!Array.isArray(parsed)) {
            if (parsed.error) {
                console.warn("RazerProvider:", parsed.error)
            }
            return []
        }

        var result = []

        for (var i = 0; i < parsed.length; i++) {
            var d = parsed[i]

            // Skips devices with no battery e.g. wired
            if (!d.percentage || d.percentage === null || d.percentage < 0) {
                continue
            }

            var device = {
                name: d.name   || "Unknown Razer Device",
                serial: d.serial || "",
                percentage: d.percentage,
                type: d.type   || "unknown",
			    icon: "",
                source: "python-openrazer",
                connectionType: 2, // Always sets device as wireless; unable to test diff between Bluetooth/Dongle connected devices
                model: "",
                objectPath: null,
                nativePath: null,
                bluetoothAddress: null,
                batteries: [],
            }

            if (device.type) {
                device.icon = DeviceUtils.getIconForType(device.type)
            }

            result.push(device)
        }

        return result
    }

    P5Support.DataSource {
        id: dataSource
        engine: "executable"
        connectedSources: []
        interval: 0

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)

            var incoming = parseRazerOutput(data["stdout"])

            var merged = root.devices.slice() // Update existing entries by serial and adds new ones

            for (var i = 0; i < incoming.length; i++) {
                var info = incoming[i]
                var found = false

                for (var j = 0; j < merged.length; j++) {
                    if (merged[j].serial && merged[j].serial === info.serial) {
                        merged[j] = info
                        found = true
                        break
                    }
                }

                if (!found) {
                    merged.push(info)
                }
            }

            // Remove devices no longer reported
            var incomingSerials = incoming.map(d => d.serial)
            merged = merged.filter(d => incomingSerials.indexOf(d.serial) !== -1)

            merged.sort((a, b) => (a.name || "").localeCompare(b.name || ""))
            root.devices = merged
        }

        Component.onCompleted: root.refresh()
    }

    // Polls device info every refreshInterval seconds (60 by default) for battery state changes
    Timer {
        interval: refreshInterval
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
