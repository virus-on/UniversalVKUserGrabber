import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1

ApplicationWindow {
    id: root

    property string currentMenu: loginMenu.menuName
    property alias  headerText: actionMenu.text

    width: 480
    height: 640
    minimumWidth: 480
    minimumHeight: 640

    title: qsTr("VK LIKE GRABBER")
    visible: true


    ToolTip {
        id: tip

        x: (parent.width - width) / 2
        y: (parent.height - 100)

        delay: 500
        timeout: 2000
        background: Rectangle {
            color: "black"
            radius: 15
        }
        font.pointSize: 16
    }

    header: TActionMenu {
        id: actionMenu

        property bool showWholeMenu: false

        threeDotsMenuVisible: true
        focus: true

        onMenuClicked: actionBarMenu.open()

        Keys.onReleased: {
            var menuList = [
                loginMenu.menuName,
                linkMenu.menuName,
                filtersMenu.menuName,
                userSelectionMenu.menuName
            ];
            if (event.key === Qt.Key_Back) {
                if (root.currentMenu === inputMenu.menuName) {
                    submitCaptcha();
                }
                else {
                    var idx = menuList.indexOf(root.currentMenu);
                    if (idx > 0)
                        root.currentMenu = menuList[idx - 1];
                    else
                        cppController.closeApp();
                }
                event.accepted = true
            }
        }

        Menu {
            id: actionBarMenu
            // With an indication of the location so that Menu pops up in the same place as in the version with Java
            x: actionMenu.width
            y: 48

            MenuItem {
                height: actionMenu.showWholeMenu ? implicitHeight : 0

                text: "Change Login"
                visible: actionMenu.showWholeMenu

                onClicked: currentMenu = loginMenu.menuName
            }
            MenuItem {
                height: actionMenu.showWholeMenu ? implicitHeight : 0

                text: "Change Link"
                visible: actionMenu.showWholeMenu

                onClicked: currentMenu = linkMenu.menuName
            }
            MenuItem {
                height: actionMenu.showWholeMenu ? implicitHeight : 0

                text: "Change Filters"
                visible: actionMenu.showWholeMenu

                onClicked: currentMenu = filtersMenu.menuName
            }
            MenuItem {
                text: "Exit"
                onClicked: cppController.closeApp();
            }
        }
    }

    Rectangle {
        anchors.fill: parent

        focus: true

        Keys.onReleased: {
            var menuList = [
                loginMenu.menuName,
                linkMenu.menuName,
                filtersMenu.menuName,
                userSelectionMenu.menuName
            ];
            if (event.key === Qt.Key_Back) {
                if (root.currentMenu === inputMenu.menuName) {
                    submitCaptcha();
                }
                else {
                    var idx = menuList.indexOf(root.currentMenu);
                    if (idx > 0)
                        root.currentMenu = menuList[idx - 1];
                    else
                        cppController.closeApp();
                }
                event.accepted = true
            }
        }

    // ----------------- Sign up menu -----------------
        Item {
            id: loginMenu

            property string menuName: "LOGIN_MENU"
            property bool isLocked: false

            anchors.fill: parent
            anchors.topMargin: -10

            visible: currentMenu == menuName

            onVisibleChanged: {
                if (visible) {
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
                if (cppController.tryAutologin()) {
                    currentMenu = linkMenu.menuName
                    showToolTip("Welcome back, " + cppController.getUsername(), 3000);
                }
                loginMenu.enabled = true;
            }

            ColumnLayout {
                anchors {
                    left:   parent.left
                    right:  parent.right
                    top:    parent.top
                    margins: 20
                }

                spacing: 8

                Label {
                    id: loginLabel

                    text: "Login"
                    padding: 12
                    font.pointSize: 16
                    font.bold: true
                }
                TTextEdit {
                    id: loginTextEdit

                    height: 40
                    Layout.fillWidth: true

                    fontSize: 16
                    maximumLength: 30
                    wrapMode: TextEdit.NoWrap
                }
                Label {
                    id: passwordLabel

                    text: "Password"
                    padding: 12
                    font.pointSize: 16
                    font.bold: true
                }
                TTextEdit {
                    id: passwordTextEdit

                    height: 40
                    Layout.fillWidth: true

                    fontSize: 16
                    maximumLength: 30
                    wrapMode: TextEdit.NoWrap
                    echoMode: TextInput.Password
                }

                Button {
                    id: signInBtn
                    enabled: loginTextEdit.text.length > 0 && passwordTextEdit.text.length >= 8

                    Layout.alignment: Qt.AlignHCenter

                    text: "  Sign in  "
                    font.pointSize: 16

                    onClicked: {
                        loginMenu.enabled = false;

                        if (cppController.auth(loginTextEdit.text, passwordTextEdit.text)) {
                            currentMenu = linkMenu.menuName
                            showToolTip("Hello, " + cppController.getUsername(), 3000);
                        }
                        else {
                            showToolTip("Auth failed for user: " + loginTextEdit.text, 3000);
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

            anchors.fill: parent
            anchors.topMargin: -10

            visible: currentMenu == menuName

            onVisibleChanged: {
                if (visible) {
                    headerText = "Input link to post"
                    actionMenu.showWholeMenu = false
                    if (!isLocked)
                        linkMenu.enabled = true
                    else
                        isLocked = false;
                }
            }

            ColumnLayout {
                anchors {
                    left:   parent.left
                    right:  parent.right
                    top:    parent.top
                    margins: 20
                }

                spacing: 8

                Label {
                    id: linkLabel

                    text: "Link"
                    padding: 12
                    font.pointSize: 16
                    font.bold: true
                }
                TTextEdit {
                    id: linkTextEdit

                    height: 40
                    Layout.fillWidth: true

                    fontSize: 16
                    wrapMode: TextEdit.NoWrap
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

            anchors {
                top:    parent.top
                left:   parent.left
                right:  parent.right
                margins:20
            }

            spacing: 10
            visible: currentMenu == menuName

            onVisibleChanged: {
                if (visible) {
                    headerText = "Set filters"
                    actionMenu.showWholeMenu = false
                    if (!isLocked)
                        filtersMenu.enabled = true
                    else
                        isLocked = false;
                }
            }


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

                    text: "any"
                    leftPadding: 24
                    checked: true
                    font.pointSize: 14

                    onCheckedChanged: {
                        if (checked)
                            gender.genderFilter = -1;
                    }
                }
                RadioButton {
                    id: maleGender

                    text: "male";
                    leftPadding: 24
                    font.pointSize: 14

                    onCheckedChanged: {
                        if (checked)
                            gender.genderFilter = 2;
                    }
                }
                RadioButton {
                    id: femaleGender

                    text: "female";
                    leftPadding: 24
                    font.pointSize: 14

                    onCheckedChanged: {
                        if (checked)
                            gender.genderFilter = 1;
                    }
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

                    text: "name"
                    leftPadding: 24
                    font.pointSize: 14
                    checked: true

                    onCheckedChanged: {
                        if (checked)
                            sort.sortType = 0;
                    }
                }

                RadioButton {
                    id: byCity

                    text: "city";
                    leftPadding: 24
                    font.pointSize: 14

                    onCheckedChanged: {
                        if (checked)
                            sort.sortType = 1;
                    }
                }

                RadioButton {
                    id: byId

                    text: "id";
                    leftPadding: 24
                    font.pointSize: 14

                    onCheckedChanged: {
                        if (checked)
                            sort.sortType = 2;
                    }
                }
            }

            Label {
                id: cityFilter

                text: "City filter"
                padding: 12
                font.pointSize: 16
                font.bold: true
            }

            TTextEdit {
                id: filterTextEdit

                height: 40
                Layout.fillWidth: true

                fontSize: 16
                wrapMode: TextEdit.NoWrap
                maximumLength: 32

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

            contentWidth: root.width
            anchors.fill: parent

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            visible: currentMenu == menuName

            onVisibleChanged: {
                if (visible) {
                    headerText = "Select User"
                    actionMenu.showWholeMenu = true
                }
            }

            ListView {
                width: parent.width

                model: userListModel
                delegate: ItemDelegate {
                    width: parent.width

                    text: NameRole + ": " + CityRole + " " + HomeTownRole
                    font.pointSize: 14
                    icon.source: (SexRole == 1 ? "qrc:/img/female_icon.png" : "qrc:/img/male_icon.png")
                    icon.width: 24
                    icon.height: 24
                    onClicked: Qt.openUrlExternally("https://vk.com/id" + IdRole)
                }
            }
        }

        ColumnLayout {
            id: inputMenu

            property string menuName: "INPUT_MENU"
            property string prevMenu: ""

            anchors {
                left:   parent.left
                right:  parent.right
                top:    parent.top
                margins: 20
            }

            visible: currentMenu == menuName

            onVisibleChanged: {
                if (visible) {
                    headerText = "Input"
                    actionMenu.showWholeMenu = false
                }
            }

            Image {
                id: captchaImage

                Layout.alignment: Qt.AlignHCenter
                source: ""
            }

            Label {
                id: codeLabel

                text: "Input " + (captchaImage.source.length == 0 ? "Code from SMS" : "Captcha")
                padding: 12
                font.pointSize: 16
                font.bold: true
            }

            TTextEdit {
                id: captchaInput

                height: 40
                Layout.fillWidth: true

                fontSize: 16
                maximumLength: 30
                wrapMode: TextEdit.NoWrap
            }

            Button {
                id: enterCodeButton

                Layout.alignment: Qt.AlignHCenter

                text: "  Send  "
                font.pointSize: 16

                onClicked: submitCaptcha();
            }
        }
    }

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
            console.debug("Unhandled lock!");
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

    function submitCaptcha()
    {
        cppController.code = captchaInput.text;
        console.debug(inputMenu.prevMenu, captchaInput.text);
        captchaInput.text = "";

        root.currentMenu = inputMenu.prevMenu;
    }
}
