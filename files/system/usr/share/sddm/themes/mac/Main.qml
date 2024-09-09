// Copyright 2022 Alexey Varfolomeev <varlesh@gmail.com>
// Used sources & ideas:
// - Joshua Krämer from https://github.com/joshuakraemer/sddm-theme-dialog
// - Suraj Mandal from https://github.com/surajmandalcell/Elegant-sddm
// - Breeze theme by KDE Visual Design Group
// - SDDM Team https://github.com/sddm/sddm
import QtQuick 2.8
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import "components"


Rectangle {
    width: 640
    height: 480
    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    property int sizeAvatar: 80
    property int longitudMasLarga: 0
    TextConstants {
        id: textConstants
    }

    // hack for disable autostart QtQuick.VirtualKeyboard
    Loader {
        id: inputPanel
        property bool keyboardActive: false
        source: "components/VirtualKeyboard.qml"
    }
    FontLoader {
        id: fontbold
        source: "fonts/SFUIText-Semibold.otf"
    }
    Connections {
        target: sddm
        onLoginSucceeded: {

        }
        onLoginFailed: {
            password.placeholderText = textConstants.loginFailed
            password.placeholderTextColor = "white"
            password.text = ""
            password.focus = false
            errorMsgContainer.visible = true
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        visible: true
        Binding on source {
            when: config.background !== undefined
            value: config.background
        }

    }

    DropShadow {
        anchors.fill: panel
        horizontalOffset: 0
        verticalOffset: 0
        radius: 0
        samples: 17
        color: "#70000000"
        source: panel
        }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.topMargin: 15

        Item {

            Image {
                id: shutdown
                height: 22
                width: 22
                source: "images/system-shutdown.svg"
                fillMode: Image.PreserveAspectFit

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        shutdown.source = "images/system-shutdown-hover.svg"
                        var component = Qt.createComponent(
                                    "components/ShutdownToolTip.qml")
                        if (component.status === Component.Ready) {
                            var tooltip = component.createObject(shutdown)
                            tooltip.x = -100
                            tooltip.y = 40
                            tooltip.destroy(600)
                        }
                    }
                    onExited: {
                        shutdown.source = "images/system-shutdown.svg"
                    }
                    onClicked: {
                        shutdown.source = "images/system-shutdown-pressed.svg"
                        sddm.powerOff()
                    }
                }
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 70
        anchors.topMargin: 15

        Item {

            Image {
                id: reboot
                height: 22
                width: 22
                source: "images/system-reboot.svg"
                fillMode: Image.PreserveAspectFit

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        reboot.source = "images/system-reboot-hover.svg"
                        var component = Qt.createComponent(
                                    "components/RebootToolTip.qml")
                        if (component.status === Component.Ready) {
                            var tooltip = component.createObject(reboot)
                            tooltip.x = -100
                            tooltip.y = 40
                            tooltip.destroy(600)
                        }
                    }
                    onExited: {
                        reboot.source = "images/system-reboot.svg"
                    }
                    onClicked: {
                        reboot.source = "images/system-reboot-pressed.svg"
                        sddm.reboot()
                    }
                }
            }
        }
    }
Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 88
        anchors.topMargin: 15
        Text {
            id: kb
            color: "#eff0f1"
            text: keyboard.layouts[keyboard.currentLayout].shortName
            font.pointSize: 12
            font.weight: Font.DemiBold
        }
    }
        Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 110
        anchors.topMargin: 15

         ComboBox {
                    id: session
                    height: 22
                    width: 150
                    model: sessionModel
                    textRole: "name"
                    displayText: ""
                    currentIndex: sessionModel.lastIndex
                    background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: "transparent"
                }


                    delegate: MenuItem {
                        id: menuitems
                        width: slistview.width * 4
                        text: session.textRole ? (Array.isArray(session.model) ? modelData[session.textRole] : model[session.textRole]) : modelData
                        highlighted: session.highlightedIndex === index
                        hoverEnabled: session.hoverEnabled
                        onClicked: {
                            ava.source = "/var/lib/AccountsService/icons/" + user.currentText
                            session.currentIndex = index
                            slistview.currentIndex = index
                            session.popup.close()
                        }
                    }
                    indicator: Rectangle{
                        anchors.right: parent.right
                        anchors.rightMargin: 9
                        height: parent.height
                        width: 22
                        color: "transparent"
                        Image{
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: width
                            fillMode: Image.PreserveAspectFit
                            source: "images/conf.svg"
                        }
                    }
                    popup: Popup {
                        width: parent.width
                        height: parent.height * menuitems.count
                        implicitHeight: slistview.contentHeight
                        margins: 0
                        contentItem: ListView {
                            id: slistview
                            clip: true
                            anchors.fill: parent
                            model: session.model
                            spacing: 0
                            highlightFollowsCurrentItem: true
                            currentIndex: session.highlightedIndex
                            delegate: session.delegate
                        }
                    }

                }
    }

        BrightnessContrast {
        anchors.fill: parent
        source: wallpaper
        brightness: 0
        contrast: 0.2
        layer.enabled: true
                               layer.effect: OpacityMask {
                               maskSource: identclock
                                }
    }
    FastBlur {
        anchors.fill: parent
        source: wallpaper
        radius: 32
        visible: listuser.visible ? false : true
        layer.enabled: true
           layer.effect: OpacityMask {
           maskSource: maskOfBlur
        }
    }
    Rectangle {
        id: maskOfBlur
        anchors.fill: parent
        color: "transparent"
        visible: false
        Rectangle {
            implicitWidth: 250
            implicitHeight: 32
            color: "#000"
            radius: 15
            anchors.bottom:  parent.bottom
            anchors.bottomMargin: baseOfUserDialog.anchors.bottomMargin + password.anchors.bottomMargin
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    Item {
    id: identclock
    width: parent.width
    height: parent.height
    opacity: 0.8
   Rectangle {
       height: 300
       width: 400
       anchors.horizontalCenter: parent.horizontalCenter
       color: "transparent"
            Clock {
            id: clock
            visible: true
            anchors.topMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }
}
}


Rectangle {
    id: baseOfUserDialog
    width: listuser.visible ? listuser.width > password.width ? listuser.width + (listuser.spacing*userModel.count) : password.width : password.width
    height: listuser.visible ? listuser.height + password.height + greetingLabel.height + password.height + password.anchors.bottomMargin + 10 : sizeAvatar + password.height + greetingLabel.height + password.height + password.anchors.bottomMargin +10
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 40
    color: "transparent"
Column {
    height: parent.height
    width: parent.width
    ListView {
                    id: listuser
                    model: userModel
                    height: userModel.count*(sizeAvatar*.9)
                    verticalLayoutDirection : ListView.TopToBottom
                    orientation: ListView.vertical
                    currentIndex: userModel.lastIndex
                    anchors.left: parent.left
                    anchors.leftMargin: baseOfUserDialog.width/2 - sizeAvatar/2
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: password.height + greetingLabel.height + password.height + password.anchors.bottomMargin + 10
                    spacing: 10
                    visible : false
                    delegate: Item {
                        id: delegate_
                        width: sizeAvatar*.9
                        height: sizeAvatar*.9


                      Image {
                           source: model.icon
                           anchors.fill: parent
                           fillMode: Image.PreserveAspectFit
                           layer.enabled: true
                           layer.effect: OpacityMask {
                               maskSource:  Rectangle {
                                   width: sizeAvatar
                                   height: sizeAvatar
                                   radius: height/2
                            }
                           }
                        }
                        Rectangle {
                            id: resalt
                            color: "#ff991c"
                            width: delegate_.width/3.5
                            height: width
                            radius: width/2
                            border.color: "white"
                            border.width: width/14
                            visible: index === userModel.lastIndex
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            Image {
                                id: palomita
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width*.6
                                height: width
                                source: "images/palomita.svg"
                                sourceSize: Qt.size(width, width)
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Text {
                           text: model.name
                           color: "white"
                           font.bold: true
                           font.pixelSize: sizeAvatar/6
                           anchors.verticalCenter: parent.verticalCenter
                           anchors.left: parent.left
                           anchors.leftMargin: delegate_.width+10
                        }
                         MouseArea {
                           anchors.fill: parent
                           onClicked: {
                               user.currentIndex = index
                               ava.source = "/var/lib/AccountsService/icons/" + user.currentText
                               listuser.visible = false
                               ava.visible = true
                               userModel.lastIndex = index
                    }
                }
                    }
                }

                        Rectangle {
                            id: mask
                            width: sizeAvatar
                            height: sizeAvatar
                            radius: sizeAvatar/2
                            visible: false
                        }

                        DropShadow {
                            anchors.fill: ava
                            width: mask.width - 4
                            height: mask.height - 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            horizontalOffset: 0
                            verticalOffset: 0
                            radius: 15.0
                            samples: 15
                            color: "#50000000"
                            source: mask
                            visible: listuser.visible ? false : true
                        }
                    Image {
                        id: ava
                        width: sizeAvatar
                        height: sizeAvatar
                        visible: true
                        fillMode: Image.PreserveAspectCrop
                        anchors.horizontalCenter: parent.horizontalCenter

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: mask
                        }
                        source: "/var/share/sddm/mac/faces/" + user.currentText
                        onStatusChanged: {
                            if (status == Image.Error)
                                return source = "/var/home/research/Pictures/hyprlock-img/.face.icon"
                        }
                         MouseArea {
                           anchors.fill: ava
                           onClicked: {
                              listuser.visible = true
                              ava.visible = false
                    }
                }
                    }

                // Custom ComboBox for hack colors on DropDownMenu
                ComboBox {
                    id: user
                    height: 40
                    width: 226
                    textRole: "name"
                    currentIndex: userModel.lastIndex
                    model: userModel
                    visible: false
                }
                Text {
                    id: usernametext
                    text: user.currentText
                    anchors.top: parent.top
                    anchors.topMargin: listuser.visible ? listuser.height + 20 : sizeAvatar + 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 20
                    font.family: fontbold.name
                    font.capitalization: Font.Capitalize
                    font.weight: Font.DemiBold
                    visible: listuser.visible ? false : true
                    color: "white"
                    layer.enabled: true
                       layer.effect: DropShadow {
                       horizontalOffset: 1
                       verticalOffset: 1
                       radius: 10
                samples: 25
                color: "#26000000"
            }
                }
                TextField {
                    id: password
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: greetingLabel.height*2
                    height: 32
                    width: 250
                    color: "#fff"
                    echoMode: TextInput.Password
                    focus: true
                    placeholderText: textConstants.password
                    visible: listuser.visible ? false : true

                    onAccepted: sddm.login(user.currentText, password.text,
                                           session.currentIndex)

                    background: Rectangle {

                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: "#fff"
                    opacity: 0.2
                    radius: 15
                    }

                    Image {
                        id: caps
                        width: 24
                        height: 24
                        opacity: 0
                        state: keyboard.capsLock ? "activated" : ""
                        anchors.right: password.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        fillMode: Image.PreserveAspectFit
                        source: "images/capslock.svg"
                        sourceSize.width: 24
                        sourceSize.height: 24

                        states: [
                            State {
                                name: "activated"
                                PropertyChanges {
                                    target: caps
                                    opacity: 1
                                }
                            },
                            State {
                                name: ""
                                PropertyChanges {
                                    target: caps
                                    opacity: 0
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                to: "activated"
                                NumberAnimation {
                                    target: caps
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: imageFadeIn
                                }
                            },

                            Transition {
                                to: ""
                                NumberAnimation {
                                    target: caps
                                    property: "opacity"
                                    from: 1
                                    to: 0
                                    duration: imageFadeOut
                                }
                            }
                        ]
                    }
                }
                Label {
                id: greetingLabel
                text: "Enter Password"
                color: "#fff"
                style: softwareRendering ? Text.Outline : Text.Normal
                visible: listuser.visible ? false : true

                styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
                font.pointSize:8
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                font.family: config.font
                font.bold: true
            }
}



                Keys.onPressed: {
                    if (event.key === Qt.Key_Return
                            || event.key === Qt.Key_Enter) {
                        sddm.login(user.currentText, password.text,
                                   session.currentIndex)
                        event.accepted = true
                    }
                }

                // Custom ComboBox for hack colors on DropDownMenu

            }
    }

