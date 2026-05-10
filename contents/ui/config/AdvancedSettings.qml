import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.1 as QQL
import org.kde.kquickcontrols as KQC

import org.kde.kirigami 2.4 as Kirigami
import org.kde.kcmutils as KCMUtils

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_debugMode: debugMode.checked

    Kirigami.FormLayout {
        id: page

        QQL.RowLayout {
            Kirigami.FormData.label: i18n("Toggle Debug mode")

            QQC2.CheckBox {
                id: debugMode
            }
        }
    }
}
