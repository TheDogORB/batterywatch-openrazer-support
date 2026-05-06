import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.1 as QQL
import org.kde.kquickcontrols as KQC

import org.kde.kirigami 2.4 as Kirigami
import org.kde.kcmutils as KCMUtils

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_fontFamily: page.cfg_fontFamily
    property alias cfg_fontBold: boldCheckBox.checked
    property alias cfg_fontWeight: fontWeight.value
    property alias cfg_fontItalic: italicCheckBox.checked
    property alias cfg_useCustomFontSize: useCustomFontSize.checked
    property alias cfg_customFontSize: customFontSize.value
    property alias cfg_useCustomIconSize: useCustomIconSize.checked
    property alias cfg_customIconSize: customIconSize.value
    // Color
    property alias cfg_useDefaultColor: useDefaultColor.checked
    property alias cfg_defaultCustomColor: defaultCustomColor.color

    property alias cfg_useChargingColor: useChargingColor.checked
    property alias cfg_chargingColor: chargingColor.color

    property alias cfg_zoneOneColor: zoneOneColor.color
    property alias cfg_useZoneOneColor: useZoneOneColor.checked
    property alias cfg_zoneOneThreshold: zoneOneThreshold.value

    property alias cfg_zoneTwoColor: zoneTwoColor.color
    property alias cfg_useZoneTwoColor: useZoneTwoColor.checked
    property alias cfg_zoneTwoThreshold: zoneTwoThreshold.value

    Kirigami.FormLayout {
        id: page

        // anchors.left: parent.left
        // anchors.right: parent.right

        // Bound to SimpleKCM cfg_fontFamily - "" = "System default"
        property string cfg_fontFamily
        // Shared width for all Spinboxes and Gridboxes
        readonly property int boxWidth: Kirigami.Units.gridUnit * 3
        readonly property int boxHeight: Kirigami.Units.gridUnit * 1.5
        // Used for bttn alignment
        readonly property int controlWidth: Kirigami.Units.gridUnit * 6

        // Fetches fonts
        ListModel {
            id: fontsModel

            Component.onCompleted: {
                const systemFont = Kirigami.Theme.defaultFont.family;
                const fonts = Qt.fontFamilies();
                const arr = [
                    {
                        // Empty value keeps sys default font
                        text: i18n("System Default (%1)", systemFont),
                        value: ""
                    }
                ];

                for (let i = 0, fontCount = fonts.length; i < fontCount; ++i) {
                    arr.push({
                        text: fonts[i],
                        value: fonts[i]
                    });
                }

                append(arr);
            }
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Tray Font Settings")
        }

        QQL.RowLayout {
            QQL.Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Font family:")

            QQC2.ComboBox {
                id: fontFamily
                model: fontsModel
                textRole: "text"
                valueRole: "value"
                currentValue: page.cfg_fontFamily

                QQL.Layout.preferredWidth: page.boxWidth * 6

                // Does not autosync -> updat explicitly on change
                onCurrentValueChanged: {
                    page.cfg_fontFamily = currentValue;
                }
            }
        }

        QQL.RowLayout {
            Kirigami.FormData.label: i18n("Style")
            QQL.Layout.fillWidth: true

            // Explicit grid to keep elements properly aligned
            // | checkbox | spinbox | -- | spacer | checkbox | italic | -- |
            // | checkbox | spinbox | px | spacer | checkbox | spacer | px |

            readonly property int controlWidth: Kirigami.Units.gridUnit * 6
            readonly property int spinWidth: Kirigami.Units.gridUnit * 4
            QQL.GridLayout {
                columns: 7
                columnSpacing: Kirigami.Units.smallSpacing
                rowSpacing: Kirigami.Units.smallSpacing

                QQC2.CheckBox {
                    id: boldCheckBox
                    text: i18n("Bold")
                    QQL.Layout.column: 0
                    QQL.Layout.row: 0
                }

                QQC2.SpinBox {
                    // CSS / Qt scale: 100 - 1000
                    id: fontWeight
                    enabled: boldCheckBox.checked
                    from: 100
                    to: 1000
                    stepSize: 100
                    QQL.Layout.column: 1
                    QQL.Layout.row: 0
                    QQL.Layout.preferredWidth: page.boxWidth
                }

                Item {
                    QQL.Layout.column: 2
                    QQL.Layout.row: 0
                }

                Item {
                    QQL.Layout.column: 3
                    QQL.Layout.row: 0
                    // Visual spacing in between elements
                    width: 5
                }

                QQC2.CheckBox {
                    id: italicCheckBox
                    text: i18n("Italic")
                    QQL.Layout.column: 4
                    QQL.Layout.row: 0
                }

                Item {
                    QQL.Layout.column: 5
                    QQL.Layout.row: 0
                }

                QQC2.CheckBox {
                    id: useCustomFontSize
                    text: i18n("Font size")
                    QQL.Layout.column: 0
                    QQL.Layout.row: 1
                }

                QQC2.SpinBox {
                    id: customFontSize
                    enabled: useCustomFontSize.checked
                    from: 4
                    to: 72
                    QQL.Layout.column: 1
                    QQL.Layout.row: 1
                    QQL.Layout.preferredWidth: page.boxWidth
                }

                QQC2.Label {
                    text: i18n("px")
                    opacity: useCustomFontSize.checked ? 0.8 : 0.5
                    verticalAlignment: Text.AlignVCenter
                    QQL.Layout.column: 2
                    QQL.Layout.row: 1
                }

                Item {
                    QQL.Layout.column: 3
                    QQL.Layout.row: 1
                    width: 5
                }

                QQC2.CheckBox {
                    id: useCustomIconSize
                    text: i18n("Icon size")
                    QQL.Layout.column: 4
                    QQL.Layout.row: 1
                }

                QQC2.SpinBox {
                    id: customIconSize
                    enabled: useCustomIconSize.checked
                    from: 8
                    to: 128
                    QQL.Layout.column: 5
                    QQL.Layout.row: 1
                    QQL.Layout.preferredWidth: page.boxWidth
                }

                QQC2.Label {
                    text: i18n("px")
                    opacity: useCustomFontSize.checked ? 0.8 : 0.5
                    verticalAlignment: Text.AlignVCenter
                    QQL.Layout.column: 6
                    QQL.Layout.row: 1
                }
            }
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Battery text colour")
        }

        QQL.RowLayout {
            Kirigami.FormData.label: i18n("Default")

            QQC2.CheckBox {
                id: useDefaultColor
            }

            KQC.ColorButton {
                id: defaultCustomColor
                enabled: useDefaultColor.checked
                showAlphaChannel: true
            }

            QQC2.Label {
                text: i18n("Charging")
                opacity: 0.7
            }

            QQC2.CheckBox {
                id: useChargingColor
            }

            KQC.ColorButton {
                id: chargingColor
                enabled: useChargingColor.checked
                showAlphaChannel: true
            }

            MouseArea {
                id: mouseColors
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
            }

            QQC2.ToolTip {
                visible: mouseColors.containsMouse
                text: i18n("Configure colors for normal and charging states. If default is turned off, system colour is used instead.")
            }
        }

        QQL.RowLayout {
            Kirigami.FormData.label: i18n("Zone 1")

            QQC2.CheckBox {
                id: useZoneOneColor
                enabled: true

                onCheckedChanged: {
                    if (!checked) {
                        useZoneTwoColor.checked = false;
                    }
                }
            }

            KQC.ColorButton {
                id: zoneOneColor
                enabled: useZoneOneColor.checked
                showAlphaChannel: true
            }

            QQC2.Label {
                opacity: useZoneOneColor.checked ? 0.8 : 0.5
                text: i18n(" below ")
            }

            QQC2.SpinBox {
                id: zoneOneThreshold
                enabled: useZoneOneColor.checked
                from: 1
                to: 100

                implicitHeight: zoneOneColor.implicitHeight
            }

            QQC2.Label {
                opacity: useZoneOneColor.checked ? 0.8 : 0.5
                text: i18n("%")
            }

            QQC2.ToolTip {
                visible: mouseZoneOne.containsMouse
                text: i18n("Applied when battery level falls below the threshold.")
            }

            MouseArea {
                id: mouseZoneOne
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
            }
        }

        QQL.RowLayout {
            Kirigami.FormData.label: i18n("Zone 2")

            QQC2.CheckBox {
                id: useZoneTwoColor
                enabled: useZoneOneColor.checked
            }

            KQC.ColorButton {
                id: zoneTwoColor
                enabled: useZoneOneColor.checked && useZoneTwoColor.checked
                showAlphaChannel: true
            }

            QQC2.Label {
                opacity: useZoneTwoColor.checked ? 1.0 : 0.5
                text: i18n(" below ")
            }

            QQC2.SpinBox {
                id: zoneTwoThreshold
                enabled: useZoneOneColor.checked && useZoneTwoColor.checked
                from: 0
                to: 100

                implicitHeight: zoneTwoColor.implicitHeight
            }

            QQC2.Label {
                opacity: useZoneTwoColor.checked ? 1.0 : 0.5
                text: i18n("%")
            }

            QQC2.ToolTip {
                visible: mouseZoneTwo.containsMouse
                text: i18n("Applied when battery level falls below the threshold.")
            }

            MouseArea {
                id: mouseZoneTwo
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
            }
        }
    }
}
