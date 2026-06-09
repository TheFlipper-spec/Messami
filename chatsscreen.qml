import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: chatsScreen
    anchors.fill: parent

    // Заглушка основного цвета, если он не определен в root
    property color primaryColor: typeof root !== 'undefined' && root.colorPrimary ? root.colorPrimary : "#8B5CF6"

    // ===== LEFT PANEL (MATTE BLACK) =====
    Rectangle {
        id: leftPanel
        height: parent.height
        width: typeof root !== 'undefined' && root.isMobile ? root.width : 320
        x: 0
        color: "#121214"

        // Тонкий разделитель
        Rectangle {
            width: 1
            height: parent.height
            anchors.right: parent.right
            color: "#1f1f22"
            visible: typeof root !== 'undefined' ? !root.isMobile : true
        }

        // Заголовок левой панели
        Rectangle {
            id: leftHeader
            width: parent.width
            height: 64
            color: "transparent"

            Text {
                text: "Чаты"
                font.bold: true
                font.pixelSize: 24
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            // Кнопка нового чата
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: "transparent"
                border.color: "#27272A"
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "+"
                    anchors.centerIn: parent
                    font.pixelSize: 20
                    color: "#A1A1AA"
                }
            }
        }

        // Заглушка списка чатов
        ListView {
            anchors.top: leftHeader.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            clip: true
            model: 5 // Фейковые чаты

            delegate: Item {
                width: parent.width
                height: 72

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: 12
                    color: index === 0 ? Qt.rgba(255,255,255, 0.05) : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12
                        anchors.verticalCenter: parent.verticalCenter

                        // Аватарка
                        Rectangle {
                            width: 48
                            height: 48
                            radius: 24
                            anchors.verticalCenter: parent.verticalCenter
                            color: index === 0 ? primaryColor : "#27272A"

                            Text {
                                text: index === 0 ? "O" : "U"
                                anchors.centerIn: parent
                                color: "white"
                                font.bold: true
                            }
                        }

                        // Текст чата
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 60
                            spacing: 4

                            Text {
                                text: index === 0 ? "Общий TCP Чат" : "User " + (index + 1)
                                color: "white"
                                font.bold: index === 0
                                font.pixelSize: 15
                            }
                            Text {
                                text: index === 0 ? "работает бро..." : "Последнее сообщение..."
                                color: "#A1A1AA"
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
        }
    }

    // ===== RIGHT PANEL =====
    Rectangle {
        id: rightPanel
        height: parent.height
        width: typeof root !== 'undefined' && root.isMobile ? root.width : parent.width - leftPanel.width
        x: typeof root !== 'undefined' && root.isMobile ? (root.isChatOpen ? 0 : root.width) : leftPanel.width
        color: "#0a0a0c"
        clip: true

        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        // 🌟 1. BACKGROUND LAYER (MESH GRADIENT) 🌟
        Item {
            id: meshBackground
            anchors.fill: parent
            z: 0
            opacity: 0.5

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: 90
                blur: 1.0
            }

            Rectangle {
                width: parent.width * 0.8
                height: parent.width * 0.8
                radius: width / 2
                color: primaryColor
                x: -width * 0.2
                y: -height * 0.2

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.25; duration: 9000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.85; duration: 9000; easing.type: Easing.InOutSine }
                }
            }

            Rectangle {
                width: parent.width * 0.65
                height: parent.width * 0.65
                radius: width / 2
                color: "#EA580C"
                x: parent.width * 0.4
                y: parent.height * 0.1

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.75; duration: 12000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.35; duration: 12000; easing.type: Easing.InOutSine }
                }
            }

            Rectangle {
                width: parent.width * 1.1
                height: parent.width * 1.1
                radius: width / 2
                color: "#2D1457"
                x: parent.width * 0.1
                y: parent.height * 0.3

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.15; duration: 15000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.90; duration: 15000; easing.type: Easing.InOutSine }
                }
            }
        }

        // 🌟 2. CHAT WINDOW OVERLAY (THE GLASS) 🌟
        Rectangle {
            id: glassOverlay
            anchors.fill: parent
            z: 1
            color: Qt.rgba(18/255, 18/255, 22/255, 0.6)

            Rectangle {
                width: 1
                height: parent.height
                anchors.left: parent.left
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: Qt.rgba(1, 1, 1, 0.05) }
                    GradientStop { position: 0.8; color: Qt.rgba(1, 1, 1, 0.05) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        // HEADER
        Rectangle {
            id: chatHeader
            width: parent.width
            height: 64
            color: Qt.rgba(18/255, 18/255, 22/255, 0.4)
            z: 10

            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: Qt.rgba(255/255, 255/255, 255/255, 0.05)
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "Общий TCP Чат"
                    font.bold: true
                    font.pixelSize: 18
                    color: "#ffffff"
                }

                Text {
                    text: typeof MessengerCore !== 'undefined' ? MessengerCore.connectionStatus : "Online"
                    color: (typeof MessengerCore !== 'undefined' && MessengerCore.connectionStatus === "Online")
                           ? "#4ade80" : "#A1A1AA"
                    font.pixelSize: 13
                }
            }

            Rectangle {
                id: dotsBtn
                width: 40
                height: 40
                radius: 20
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                color: dotsMouse.containsMouse ? Qt.rgba(255/255, 255/255, 255/255, 0.1) : "transparent"

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    text: "⋮"
                    anchors.centerIn: parent
                    font.pixelSize: 22
                    font.bold: true
                    color: "#a1a1aa"
                }

                MouseArea {
                    id: dotsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }

        // ===== CHAT LIST =====
        ListView {
            id: chatList
            anchors.top: chatHeader.bottom
            anchors.bottom: inputContainer.top
            anchors.left: parent.left
            anchors.right: parent.right
            z: 10

            clip: true
            spacing: 4 // Плотно сгруппированные сообщения
            topMargin: 20
            bottomMargin: 20

            model: typeof MessengerCore !== 'undefined' && MessengerCore.chatModel ? MessengerCore.chatModel : 0
            onCountChanged: Qt.callLater(positionViewAtEnd)

            ScrollBar.vertical: ScrollBar {
                id: vBar
                policy: ScrollBar.AlwaysOn
                width: 8
                hoverEnabled: true
                anchors.right: parent.right
                anchors.rightMargin: 2

                background: Item {}

                contentItem: Rectangle {
                    width: 6
                    radius: 3
                    color: "#ffffff"
                    opacity: 0.2
                }

                opacity: (chatList.containsMouse || active) ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            delegate: Item {
                width: chatList.width
                height: bubbleWrapper.height

                Item {
                    id: bubbleWrapper
                    x: model.isMine ? (parent.width - width - 20) : 20
                    width: Math.min(Math.max(msgText.implicitWidth + 40, 80), parent.width * 0.75)
                    height: msgText.implicitHeight + 24

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#000000"
                        shadowOpacity: 0.25
                        shadowBlur: 12
                        shadowVerticalOffset: 4
                    }

                    Rectangle {
                        id: bubble
                        anchors.fill: parent
                        radius: 18

                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: model.isMine ? primaryColor : Qt.rgba(39/255, 39/255, 42/255, 0.8)
                            }
                            GradientStop {
                                position: 1.0
                                color: model.isMine ? Qt.darker(primaryColor, 1.2) : Qt.rgba(39/255, 39/255, 42/255, 0.8)
                            }
                        }

                        border.color: Qt.rgba(255/255, 255/255, 255/255, 0.1)
                        border.width: 1

                        Text {
                            id: msgText
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 10
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

                            text: model.messageText
                            wrapMode: Text.Wrap
                            font.pixelSize: 15
                            color: "#F4F4F5"
                            lineHeight: 1.2
                        }

                        Text {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.bottomMargin: 8
                            anchors.rightMargin: 16
                            text: model.timestamp
                            font.pixelSize: 11
                            color: Qt.rgba(255/255, 255/255, 255/255, 0.5)
                        }
                    }
                }
            }
        }

        // ===== INPUT =====
        Item {
            id: inputContainer
            width: parent.width
            height: 90
            anchors.bottom: parent.bottom
            z: 10

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(10/255, 10/255, 12/255, 0.8) }
                    GradientStop { position: 1.0; color: "#0a0a0c" }
                }
            }

            function triggerSend() {
                if (inputField.text.trim().length > 0) {
                    if (typeof MessengerCore !== 'undefined') {
                        MessengerCore.sendMessage(inputField.text)
                    } else {
                        console.log("Эмуляция отправки:", inputField.text)
                    }
                    inputField.clear()
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 40
                height: 52
                radius: 26
                color: Qt.rgba(30/255, 30/255, 36/255, 0.8)
                border.color: Qt.rgba(255/255, 255/255, 255/255, 0.1)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    spacing: 4

                    // Кнопка прикрепления файлов (Скрепка)
                    AbstractButton {
                        id: attachButton
                        width: 40
                        height: 40
                        Layout.alignment: Qt.AlignVCenter
                        hoverEnabled: true

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        background: Rectangle {
                            radius: 20
                            color: attachButton.hovered ? Qt.rgba(255/255, 255/255, 255/255, 0.08) : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Item {
                            anchors.fill: parent

                            Image {
                                id: attachmentIcon
                                anchors.centerIn: parent
                                source: "qrc:/Messami/Resources/icons/paperclip.svg"
                                sourceSize: Qt.size(22, 22) // Важно для четкости SVG
                                fillMode: Image.PreserveAspectFit

                                // 🎯 Вот магия перекраски:
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    colorization: 1.0
                                    colorizationColor: attachButton.hovered ? "#FFFFFF" : "#A1A1AA"
                                }
                            }
                        }

                        onClicked: {
                            console.log("Открытие меню файлов...")
                        }
                    }

                    // Поле ввода
                    TextField {
                        id: inputField
                        Layout.fillWidth: true
                        color: "#ffffff"
                        placeholderText: "Написать сообщение..."
                        placeholderTextColor: "#71717a"
                        background: Item {}
                        onAccepted: inputContainer.triggerSend()
                        font.pixelSize: 15
                        verticalAlignment: TextInput.AlignVCenter
                    }

                    // Кнопка отправки
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: inputField.text.length > 0 ? primaryColor : "#27272A"
                        Layout.alignment: Qt.AlignVCenter

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            text: "↑"
                            anchors.centerIn: parent
                            color: inputField.text.length > 0 ? "white" : "#71717a"
                            font.pixelSize: 20
                            font.bold: true
                            anchors.verticalCenterOffset: -1
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: inputContainer.triggerSend()
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
    }
}
