import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.1 as QQL
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

    Kirigami.FormLayout {
        id: page

        // anchors.left: parent.left
        // anchors.right: parent.right

        // Bound to SimpleKCM cfg_fontFamily - "" = "System default"
        property string cfg_fontFamily
        // Shared width for all Spinboxes
        readonly property int boxWidth: Kirigami.Units.gridUnit * 3

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
            Kirigami.FormData.label: i18n("Applet Tray Settings")
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
                    opacity: 0.7
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
                    opacity: 0.7
                    verticalAlignment: Text.AlignVCenter
                    QQL.Layout.column: 6
                    QQL.Layout.row: 1
                }
            }
        }
    }
}
