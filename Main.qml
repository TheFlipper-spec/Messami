import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Effects
import Messami // FIX: Заменили MigMeus на Messami

ApplicationWindow {
    id: root
    visible: false // FIX: Обязательно false! Окно покажет C++ код (window->show())
    width: 900
    height: 600
    title: "Messami" // FIX

    // === ЦВЕТА ===
    property bool isMobile: width < 700
    property bool isChatOpen: !isMobile

    property color colorPrimary:      "#8b5cf6"
    property color colorBgLeft:       "#18181b"
    property color colorBgRight:      "#09090b"
    property color colorBubbleMine:   "#8b5cf6"
    property color colorBubbleOther:  "#27272a"
    property color colorTextMain:     "#fafafa"
    property color colorTextSub:      "#a1a1aa"
    property color colorDivider:      "#27272a"

    color: colorBgLeft

    // ==========================================
    // КАСТОМНЫЙ ЗАГОЛОВОК ОКНА
    // ==========================================
    Rectangle {
        id: customTitleBar
        width: parent.width
        height: 32
        color: root.colorBgLeft
        z: 100

        MouseArea {
            anchors.fill: parent
            onPressed: root.startSystemMove()
            onDoubleClicked: {
                if (root.visibility === Window.Maximized) {
                    root.showNormal()
                } else {
                    root.showMaximized()
                }
            }
        }

        Row {
            anchors.right: parent.right
            height: parent.height

            Rectangle {
                width: 46
                height: parent.height
                color: minMouse.containsMouse ? "#3f3f46" : "transparent"

                Text {
                    text: "—"
                    color: root.colorTextSub
                    anchors.centerIn: parent
                    font.pixelSize: 12
                }

                MouseArea {
                    id: minMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.showMinimized()
                }
            }

            Rectangle {
                width: 46
                height: parent.height
                color: maxMouse.containsMouse ? "#3f3f46" : "transparent"

                Text {
                    text: root.visibility === Window.Maximized ? "❐" : "☐"
                    color: root.colorTextSub
                    anchors.centerIn: parent
                    font.pixelSize: 14
                }

                MouseArea {
                    id: maxMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.visibility === Window.Maximized) {
                            root.showNormal()
                        } else {
                            root.showMaximized()
                        }
                    }
                }
            }

            Rectangle {
                width: 46
                height: parent.height
                color: closeMouse.containsMouse ? "#e11d48" : "transparent"

                Text {
                    text: "✕"
                    color: closeMouse.containsMouse ? "white" : root.colorTextSub
                    anchors.centerIn: parent
                    font.pixelSize: 14
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Qt.quit()
                }
            }
        }
    }

    // ==========================================
    // ОСНОВНОЙ ИНТЕРФЕЙС
    // ==========================================
    Item {
        anchors.top: customTitleBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        // ЛЕВАЯ ПАНЕЛЬ
        Rectangle {
            id: leftPanel
            height: parent.height
            width: root.isMobile ? root.width : 320
            x: 0
            color: root.colorBgLeft

            Rectangle {
                width: 1
                height: parent.height
                anchors.right: parent.right
                color: root.colorDivider
                visible: !root.isMobile
            }

            Rectangle {
                id: leftHeader
                width: parent.width
                height: 60
                color: "transparent"

                Text {
                    text: "Чаты"
                    font.bold: true
                    font.pixelSize: 24
                    color: root.colorTextMain
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                }
            }

            ListView {
                anchors.top: leftHeader.bottom
                anchors.bottom: parent.bottom
                width: parent.width
                clip: true

                model: ListModel {
                    ListElement { name: "Общий TCP Чат"; lastMsg: "Тестовый сервер tcpbin" }
                    ListElement { name: "Илон Маск";     lastMsg: "Как там ракета?" }
                }

                delegate: Rectangle {
                    width: parent.width - 20
                    height: 76
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 16
                    color: contactMouse.pressed ? "#3f3f46" : (contactMouse.containsMouse ? "#27272a" : "transparent")

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    Rectangle {
                        id: avatar
                        width: 50
                        height: 50
                        radius: 25
                        color: root.colorPrimary
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        Text {
                            text: name.charAt(0)
                            color: "white"
                            font.bold: true
                            font.pixelSize: 20
                            anchors.centerIn: parent
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: avatar.right
                        anchors.leftMargin: 15

                        Text {
                            text: name
                            font.bold: true
                            font.pixelSize: 16
                            color: root.colorTextMain
                        }

                        Text {
                            text: lastMsg
                            color: root.colorTextSub
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            width: 200
                        }
                    }

                    MouseArea {
                        id: contactMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.isChatOpen = true
                    }
                }
            }
        }

        // ПРАВАЯ ПАНЕЛЬ
        Rectangle {
            id: rightPanel
            height: parent.height
            width: root.isMobile ? root.width : root.width - leftPanel.width
            x: root.isMobile ? (root.isChatOpen ? 0 : root.width) : leftPanel.width
            color: root.colorBgRight
            z: root.isMobile ? 10 : 1

            Behavior on x {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutQuart
                }
            }

            Rectangle {
                id: chatHeader
                width: parent.width
                height: 60
                color: root.colorBgLeft

                Rectangle {
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.bottom
                    color: root.colorDivider
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15

                    Rectangle {
                        visible: root.isMobile
                        width: 40
                        height: 40
                        radius: 20
                        color: backMouse.pressed ? "#27272a" : "transparent"

                        Text {
                            text: "❮"
                            font.pixelSize: 20
                            color: root.colorPrimary
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: backMouse
                            anchors.fill: parent
                            onClicked: root.isChatOpen = false
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "Общий TCP Чат"
                            font.bold: true
                            font.pixelSize: 16
                            color: root.colorTextMain
                        }

                        Text {
                            // Убедись, что MessengerCore зарегистрирован в Messami
                            text: MessengerCore.connectionStatus
                            color: MessengerCore.connectionStatus === "Online" ? "#4ade80" : "#f87171"
                            font.pixelSize: 12
                        }
                    }
                }
            }

            ListView {
                id: chatList
                anchors.top: chatHeader.bottom
                anchors.bottom: inputContainer.top
                width: parent.width
                clip: true
                spacing: 10
                topMargin: 20
                bottomMargin: 20

                model: MessengerCore.chatModel
                onCountChanged: Qt.callLater(chatList.positionViewAtEnd)

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 250
                    }
                    NumberAnimation {
                        property: "y"
                        from: y + 30
                        duration: 350
                        easing.type: Easing.OutBack
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        property: "y"
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                delegate: Item {
                    width: chatList.width
                    height: bubble.height

                    Rectangle {
                        id: bubble
                        x: model.isMine ? (parent.width - width - 20) : 20
                        width: Math.min(Math.max(msgText.implicitWidth + 30, 80), parent.width - 80)
                        height: msgText.implicitHeight + 24
                        color: model.isMine ? root.colorBubbleMine : root.colorBubbleOther
                        radius: 18

                        Text {
                            id: msgText
                            anchors.centerIn: parent
                            width: parent.width - 24
                            text: model.messageText
                            font.pixelSize: 16
                            wrapMode: Text.Wrap
                            color: root.colorTextMain
                        }

                        Text {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.bottomMargin: 4
                            anchors.rightMargin: 12
                            text: model.timestamp
                            font.pixelSize: 10
                            color: model.isMine ? "#c4b5fd" : "#71717a"
                        }
                    }
                }
            }

            Rectangle {
                id: inputContainer
                width: parent.width
                height: 80
                anchors.bottom: parent.bottom
                color: root.colorBgRight

                function triggerSend() {
                    if (inputField.text.trim().length > 0) {
                        MessengerCore.sendMessage(inputField.text)
                        inputField.clear()
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 30
                    height: 50
                    radius: 25
                    color: "#27272a"
                    border.color: "#3f3f46"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 6

                        TextField {
                            id: inputField
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: root.colorTextMain
                            placeholderText: "Написать сообщение..."
                            placeholderTextColor: root.colorTextSub
                            font.pixelSize: 16
                            background: Item {}

                            onAccepted: {
                                inputContainer.triggerSend()
                            }
                        }

                        Rectangle {
                            id: sendBtn
                            width: 38
                            height: 38
                            radius: 19
                            color: inputField.text.trim().length > 0 ? root.colorPrimary : "#3f3f46"

                            scale: sendMouseArea.pressed ? 0.85 : 1.0

                            Behavior on scale {
                                NumberAnimation { duration: 150 }
                            }

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }

                            Text {
                                text: "➤"
                                font.pixelSize: 18
                                color: inputField.text.trim().length > 0 ? "#ffffff" : "#71717a"
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: 1
                            }

                            MouseArea {
                                id: sendMouseArea
                                anchors.fill: parent
                                onClicked: {
                                    inputContainer.triggerSend()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
