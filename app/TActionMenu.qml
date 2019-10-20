import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.1

ToolBar {
    id: root
    height: 48
    property alias  text: headerLabel.text
    property bool   threeDotsMenuVisible: false

    signal menuClicked()

    Rectangle {
        anchors.fill: parent
        color: "#080808"

        Text {
            id: headerLabel
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 20 + 12
            }

            text: "Sign in"
            font.pointSize: 18
            font.bold: true
            color: "white"
        }
        ToolButton {
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            visible: threeDotsMenuVisible
            text: qsTr("⋮")
            onClicked: root.menuClicked()
        }
    }
}
