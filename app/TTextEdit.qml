import QtQuick 2.9
import QtQuick.Controls 2.3

Rectangle {
    property alias maximumLength: txtEdit.maximumLength
    property alias wrapMode: txtEdit.wrapMode
    property alias text: txtEdit.text
    property alias fontSize: txtEdit.font.pointSize
    property alias echoMode: txtEdit.echoMode

    border.color: "black"
    border.width: 2
    radius: 40

    TextInput {
        id: txtEdit

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 12
            rightMargin: 12
        }

        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
        echoMode: TextInput.Normal
        wrapMode: TextEdit.NoWrap
        layer.enabled: true
    }
}
