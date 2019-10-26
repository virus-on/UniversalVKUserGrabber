import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1

ApplicationWindow {
    id: root
    visible: true
    width: 480
    height: 640
    minimumHeight: 640
    minimumWidth: 480
    title: qsTr("VK LIKE GRABBER")

    property string currentMenu: loginMenu.menuName
    property alias  headerText: actionMenu.text

    function lockMenuOnVisibleChangeState(menuName)
    {
        if (menuName === loginMenu.menuName)
            loginMenu.isLocked = true;
        else if (menuName === linkMenu.menuName)
            linkMenu.isLocked = true;
        else if (menuName === filtersMenu.menuName)
            filtersMenu.isLocked = true;
        else if (menuName === userSelectionMenu.menuName)
            userSelectionMenu.isLocked = true;
        else
            console.log("Unhandled lock!");
    }

    function goToInput(imgUrl)
    {
        captchaImage.source = imgUrl;
        lockMenuOnVisibleChangeState(root.currentMenu);
        inputMenu.prevMenu = root.currentMenu;
        root.currentMenu = inputMenu.menuName;
    }

    function showToolTip(text, time){
        tip.timeout = time;
        tip.text = text;
        tip.visible = true;
    }

    ToolTip {
        id: tip
        delay: 500
        timeout: 2000
        background: Rectangle {
            color: "black"
            radius: 15
        }
        font.pointSize: 16
        x: (parent.width - width) / 2
        y: (parent.height - 100)
    }

    header: TActionMenu {
        id: actionMenu
        threeDotsMenuVisible: true

        property bool showWholeMenu: false

        onMenuClicked: actionBarMenu.open()
        Menu {
            id: actionBarMenu
            // With an indication of the location so that Menu pops up in the same place as in the version with Java
            x: actionMenu.width
            y: 48

            MenuItem {
                visible: actionMenu.showWholeMenu
                height: actionMenu.showWholeMenu ? implicitHeight : 0
                text: "Change Login"
                onClicked: currentMenu = loginMenu.menuName
            }
            MenuItem {
                visible: actionMenu.showWholeMenu
                height: actionMenu.showWholeMenu ? implicitHeight : 0
                text: "Change Link"
                onClicked: currentMenu = linkMenu.menuName
            }
            MenuItem {
                visible: actionMenu.showWholeMenu
                height: actionMenu.showWholeMenu ? implicitHeight : 0
                text: "Change Filters"
                onClicked: currentMenu = filtersMenu.menuName
            }
            MenuItem {
                text: "Exit"
                onClicked: cppController.closeApp();
            }
        }

    }


    // ----------------- Sign up menu -----------------
    Item {
        id: loginMenu
        property string menuName: "LOGIN_MENU"
        property bool isLocked: false
        visible: currentMenu == menuName
        anchors.fill: parent
        anchors.topMargin: -10

        onVisibleChanged: {
            if (visible)
            {
                headerText = "Sign in"
                actionMenu.showWholeMenu = false
                if (!isLocked)
                    loginMenu.enabled = true
                else
                    isLocked = false;
            }
        }

        Component.onCompleted: {
            loginMenu.enabled = false;
            if (cppController.tryAutologin())
            {
                currentMenu = linkMenu.menuName
                showToolTip("Welcome back, " + cppController.getUsername(), 3000);
            }
            loginMenu.enabled = true;
        }

        ColumnLayout {
            spacing: 8

            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.top:    parent.top
            anchors.margins: 20

            Label {
                padding: 12
                id: loginLabel
                text: "Login"
                font.pointSize: 16
                font.bold: true
            }
            TTextEdit {
                Layout.fillWidth: true
                height: 40
                fontSize: 16
                maximumLength: 30
                wrapMode: TextEdit.NoWrap
                id: loginTextEdit
            }
            Label {
                padding: 12
                id: passwordLabel
                text: "Password"
                font.pointSize: 16
                font.bold: true
            }
            TTextEdit {
                Layout.fillWidth: true
                height: 40
                fontSize: 16
                maximumLength: 30
                wrapMode: TextEdit.NoWrap
                id: passwordTextEdit
                echoMode: TextInput.Password
            }

            Button {
                id: signInBtn
                Layout.alignment: Qt.AlignHCenter
                text: "  Sign in  "
                font.pointSize: 16
                onClicked: {
                    loginMenu.enabled = false;

                    if (cppController.auth(loginTextEdit.text, passwordTextEdit.text))
                    {
                        currentMenu = linkMenu.menuName
                        showToolTip("Hello, " + cppController.getUsername(), 3000);
                    }
                    loginMenu.enabled = true;
                }
            }
        }
    }


    // ----------------- Link input menu -----------------
    Item {
        id: linkMenu
        property string menuName: "LINK_INPUT_MENU"
        property bool isLocked: false
        visible: currentMenu == menuName
        anchors.fill: parent
        anchors.topMargin: -10

        onVisibleChanged: {
            if (visible)
            {
                headerText = "Input link to post"
                actionMenu.showWholeMenu = false
                if (!isLocked)
                    linkMenu.enabled = true
                else
                    isLocked = false;
            }
        }

        ColumnLayout {
            spacing: 8

            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.top:    parent.top
            anchors.margins: 20

            Label {
                padding: 12
                id: linkLabel
                text: "Link"
                font.pointSize: 16
                font.bold: true
            }
            TTextEdit {
                Layout.fillWidth: true
                height: 40
                fontSize: 16
                wrapMode: TextEdit.NoWrap
                id: linkTextEdit
            }

            Button {
                id: grabUsersBtn
                Layout.alignment: Qt.AlignHCenter
                text: " Grab users "
                font.pointSize: 16
                onClicked: {
                    linkMenu.enabled = false;

                    if (cppController.getLikes(linkTextEdit.text))
                        currentMenu = filtersMenu.menuName
                    linkMenu.enabled = true;
                }
            }
        }
    }


    // ----------------- Filters menu -----------------
    ColumnLayout {
        id: filtersMenu
        property string menuName: "FILTERS_MENU"
        property bool isLocked: false
        visible: currentMenu == menuName
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        onVisibleChanged: {
            if (visible)
            {
                headerText = "Set filters"
                actionMenu.showWholeMenu = false
                if (!isLocked)
                    filtersMenu.enabled = true
                else
                    isLocked = false;
            }
        }

        anchors.margins: 20
        spacing: 10

        ColumnLayout {
            id: gender
            property int genderFilter: -1
            spacing: 2

            Label {
                id: genderLabel
                text: "Gender:"
                font.pointSize: 16
                font.bold: true
                leftPadding: 12
            }

            RadioButton {
                id: noGender
                leftPadding: 24
                checked: true
                text: "any"
                onCheckedChanged: {
                    if (checked)
                        gender.genderFilter = -1;
                }
                font.pointSize: 14
            }
            RadioButton {
                id: maleGender
                leftPadding: 24
                text: "male";
                onCheckedChanged: {
                    if (checked)
                        gender.genderFilter = 2;
                }
                font.pointSize: 14
            }
            RadioButton {
                id: femaleGender
                leftPadding: 24
                text: "female";
                onCheckedChanged: {
                    if (checked)
                        gender.genderFilter = 1;
                }
                font.pointSize: 14
            }
        }

        ColumnLayout {
            id: sort
            property int sortType: 0
            spacing: 2

            Label {
                id: sortLabel
                text: "Sort by:"
                font.pointSize: 16
                font.bold: true
                leftPadding: 12
            }

            RadioButton {
                id: byName
                leftPadding: 24
                checked: true
                text: "name"
                onCheckedChanged: {
                    if (checked)
                        sort.sortType = 0;
                }
                font.pointSize: 14
            }
            RadioButton {
                id: byCity
                leftPadding: 24
                text: "city";
                onCheckedChanged: {
                    if (checked)
                        sort.sortType = 1;
                }
                font.pointSize: 14
            }
            RadioButton {
                id: byId
                leftPadding: 24
                text: "id";
                onCheckedChanged: {
                    if (checked)
                        sort.sortType = 2;
                }
                font.pointSize: 14
            }
        }

        Label {
            padding: 12
            id: cityFilter
            text: "City filter"
            font.pointSize: 16
            font.bold: true
        }

        TTextEdit {
            Layout.fillWidth: true
            height: 40
            fontSize: 16
            wrapMode: TextEdit.NoWrap
            maximumLength: 32
            id: filterTextEdit
        }

        Button {
            id: setFiltersBtn
            Layout.alignment: Qt.AlignHCenter
            text: " Set filters "
            font.pointSize: 16
            onClicked: {
                cppController.setFiltersAndAddUsers(gender.genderFilter, sort.sortType, filterTextEdit.text);
                currentMenu = userSelectionMenu.menuName;
            }
        }
    }


    // ----------------- Selection menu -----------------
    ScrollView {
        id: userSelectionMenu
        property string menuName: "SELECTION_MENU"
        property bool isLocked: false
        visible: currentMenu == menuName
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentWidth: root.width

        onVisibleChanged: {
            if (visible)
            {
                headerText = "Select User"
                actionMenu.showWholeMenu = true
            }
        }

        anchors.fill: parent

        ListView {
            width: parent.width
            model: userListModel
            delegate: ItemDelegate {
                text: NameRole + ": " + CityRole + " " + HomeTownRole
                width: parent.width
                font.pointSize: 14
                icon.source: (SexRole == 1 ? "qrc:/img/female_icon.png" : "qrc:/img/male_icon.png")
                icon.width: 24
                icon.height: 24
                onClicked: {
                    var url = "https://vk.com/id" + IdRole;
                    Qt.openUrlExternally(url)
                }
            }
        }
    }

    ColumnLayout {
        id: inputMenu
        property string menuName: "INPUT_MENU"
        visible: currentMenu == menuName
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.top:    parent.top
        anchors.margins: 20

        property string prevMenu: ""

        onVisibleChanged: {
            if (visible)
            {
                headerText = "Input"
                actionMenu.showWholeMenu = false
            }
        }

        Image {
            id: captchaImage
            source: ""
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            id: codeLabel
            padding: 12
            text: "Input " + (captchaImage.source.length == 0 ? "Code from SMS" : "Captcha")
            font.pointSize: 16
            font.bold: true
        }

        TTextEdit {
            id: captchaInput
            Layout.fillWidth: true
            height: 40
            fontSize: 16
            maximumLength: 30
            wrapMode: TextEdit.NoWrap
        }

        Button {
            id: enterCodeButton
            Layout.alignment: Qt.AlignHCenter
            text: "  Send  "
            font.pointSize: 16
            onClicked: {
                cppController.code = captchaInput.text;
                console.log(inputMenu.prevMenu, captchaInput.text);
                captchaInput.text = "";

                root.currentMenu = inputMenu.prevMenu;
            }
        }

    }
}
