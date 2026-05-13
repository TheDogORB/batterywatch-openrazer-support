import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.1 as QQL
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kcmutils as KCMUtils

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_enableOpenLinkHubIntegration: enableOpenLinkHubIntegration.checked
    property alias cfg_openLinkHubApiPort: openLinkHubApiPort.value

    property alias cfg_useOpenRazerIntegration: useOpenRazerIntegration.checked
    property alias cfg_openRazerPollingTime: openRazerPollingTime.value

    Kirigami.FormLayout {
        id: page

        // anchors.left: parent.left
        // anchors.right: parent.right

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("OpenLinkHub Integration")
        }

        QQC2.CheckBox {
            id: enableOpenLinkHubIntegration
            Kirigami.FormData.label: i18n("Enable: ")
            text: i18n("Enabled")
        }

        QQC2.SpinBox {
            id: openLinkHubApiPort
            Kirigami.FormData.label: i18n("Port: ")
            to: 65535
            enabled: enableOpenLinkHubIntegration.checked
        }
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Open Razer Integration")
        }

        QQL.RowLayout {
            Kirigami.FormData.label: i18n("Enable")

            QQC2.CheckBox {
                id: useOpenRazerIntegration
            }
        }

        QQL.RowLayout {
            Kirigami.FormData.label: i18n("Polling timer")

            QQC2.SpinBox {
                id: openRazerPollingTime
                enabled: useOpenRazerIntegration.checked
                from: 1
                to: 3600
            }

            QQC2.Label {
                text: i18n("s")
                opacity: useOpenRazerIntegration.checked ? 0.7 : 0.5
            }
        }
    }
}
