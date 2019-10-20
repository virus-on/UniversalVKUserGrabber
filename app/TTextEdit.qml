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
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        id: txtEdit
        wrapMode: TextEdit.NoWrap
    }
}
