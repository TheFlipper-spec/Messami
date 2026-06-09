import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Effects
import Messami

ApplicationWindow {
    id: root
    visible: false
    width: 900
    height: 600
    title: "Messami"

    property bool isMobile: width < 700
    property bool isChatOpen: !isMobile

    // Цвета доступны из всех вложенных экранов через префикс root
    property color colorPrimary:      "#7C3AED"
    property color colorTitleBar:     "#09090b"
    property color colorBgLeft:       "#18181b"
    property color colorBgRight:      "#171A1F"
    property color colorBubbleMine:   "#7C3AED"
    property color colorBubbleOther:  "#1F2329"
    property color colorTextMain:     "#fafafa"
    property color colorTextSub:      "#a1a1aa"
    property color colorDivider:      "#27272a"

    color: colorBgLeft

    // ================= TITLE BAR =================
    Rectangle {
        id: customTitleBar
        width: parent.width
        height: 32
        color: root.colorTitleBar
        z: 100

        // Тонкая разделительная полоса
        Rectangle {
            // Динамический расчет ширины:
            // Если в стеке 1 элемент (экран входа) — полоса на весь экран.
            // Если элементов больше (экран чата) — полоса ужмется до границы левой панели (320px).
            width: mainStack.depth <= 1
                   ? parent.width
                   : (root.isMobile ? root.width : 320)

            height: 1
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: root.colorDivider

            // Плавный переход ширины при переключении экранов
            Behavior on width { NumberAnimation { duration: 150 } }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: root.startSystemMove()
            onDoubleClicked: {
                if (root.visibility === Window.Maximized) root.showNormal()
                else root.showMaximized()
            }
        }

        Row {
            anchors.right: parent.right
            height: parent.height

            Rectangle {
                width: 46; height: parent.height
                color: minMouse.containsMouse ? "#3f3f46" : "transparent"
                Text { text: "—"; anchors.centerIn: parent; color: root.colorTextSub }
                MouseArea { id: minMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.showMinimized() }
            }

            Rectangle {
                width: 46; height: parent.height
                color: maxMouse.containsMouse ? "#3f3f46" : "transparent"
                Text { text: root.visibility === Window.Maximized ? "❐" : "☐"; anchors.centerIn: parent; color: root.colorTextSub }
                MouseArea { id: maxMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.visibility === Window.Maximized ? root.showNormal() : root.showMaximized() }
            }

            Rectangle {
                width: 46; height: parent.height
                color: closeMouse.containsMouse ? "#e11d48" : "transparent"
                Text { text: "✕"; anchors.centerIn: parent; color: root.colorTextSub }
                MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.close() }
            }
        }
    }

    // ================= НАВИГАЦИЯ (STACK VIEW) =================
    StackView {
        id: mainStack
        anchors.top: customTitleBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Component.onCompleted: {
            // 1. Сначала загружаем экран входа/регистрации
            let loginScreen = mainStack.push(Qt.resolvedUrl("loginscreen.qml"))

            // 2. Слушаем сигнал успешного входа
            if (loginScreen !== null && loginScreen.loginSuccessful !== undefined) {
                loginScreen.loginSuccessful.connect(function() {
                    // 3. Заменяем экран входа на экран чатов
                    mainStack.replace(null, Qt.resolvedUrl("chatsscreen.qml"))
                })
            }
        }

        pushEnter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 300 } }
        pushExit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 300 } }
    }
}
