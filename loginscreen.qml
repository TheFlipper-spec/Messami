import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes

Item {
    id: loginScreen
    anchors.fill: parent

    signal loginSuccessful()
    signal qrLoginRequested() // Сигнал для обработки входа по QR-коду

    // ================= 🎨 СОСТОЯНИЕ ТЕМЫ И СТИЛИЗАЦИЯ 🎨 =================
    property bool isDarkTheme: true

    // Динамические цвета темы (переключаются плавно)
    property color colorBg: isDarkTheme ? "#121214" : "#f4f4f5"
    property color colorCardBg: isDarkTheme ? "#1c1c1f" : "#ffffff"
    property color colorBorder: isDarkTheme ? "#27272a" : "#e4e4e7"
    property color colorTextMain: isDarkTheme ? "#fafafa" : "#18181b"
    property color colorTextSub: isDarkTheme ? "#a1a1aa" : "#71717a"
    property color colorInputBg: isDarkTheme ? "#1c1c1f" : "#f4f4f5"

    // Текущий индекс языка: 0 - RU, 1 - EN, 2 - ES, 3 - ZH, 4 - PT-PT, 5 - PT-BR
    property int currentLang: 1

    // Массив данных локализации
    readonly property var translations: [
        {
            code: "RU",
            name: "Русский",
            welcome: "Добро пожаловать!",
            sub: "Введите номер для входа в Messami",
            placeholder: "Номер телефона",
            continueText: "Продолжить",
            orText: "или",
            qrText: "Войти по QR-коду"
        },
        {
            code: "EN",
            name: "English",
            welcome: "Welcome back!",
            sub: "Enter your number to sign in",
            placeholder: "Phone number",
            continueText: "Continue",
            orText: "or",
            qrText: "Sign in with QR code"
        },
        {
            code: "ES",
            name: "Español",
            welcome: "¡Bienvenido!",
            sub: "Ingrese su número para iniciar sesión",
            placeholder: "Número de teléfono",
            continueText: "Continuar",
            orText: "o",
            qrText: "Entrar con código QR"
        },
        {
            code: "ZH",
            name: "简体中文",
            welcome: "欢迎回来！",
            sub: "输入您的电话号码以登录 Messami",
            placeholder: "电话号码",
            continueText: "继续",
            orText: "或",
            qrText: "使用二维码登录"
        },
        {
            code: "PT-PT",
            name: "Português (Portugal)",
            welcome: "Bem-vindo!",
            sub: "Insira o seu número para entrar no Messami",
            placeholder: "Número de telemóvel",
            continueText: "Continuar",
            orText: "ou",
            qrText: "Entrar com código QR"
        },
        {
            code: "PT-BR",
            name: "Português (Brasil)",
            welcome: "Boas-vindas!",
            sub: "Insira seu número для входа в Messami",
            placeholder: "Número de celular",
            continueText: "Continuar",
            orText: "ou",
            qrText: "Entrar com código QR"
        }
    ]

    // Быстрый доступ к строкам перевода
    property string textWelcome: translations[currentLang].welcome
    property string textSub: translations[currentLang].sub
    property string textPhonePlaceholder: translations[currentLang].placeholder
    property string textContinue: translations[currentLang].continueText
    property string textOr: translations[currentLang].orText
    property string textQr: translations[currentLang].qrText

    // ================= 🌍 АВТООПРЕДЕЛЕНИЕ СИСТЕМНОГО ЯЗЫКА И ГЕО 🌍 =================
    Component.onCompleted: {
        // 1. Автоопределение языка системы
        let sysLocale = Qt.locale().name.toLowerCase()
        let targetIndex = 1

        if (sysLocale.startsWith("ru")) {
            targetIndex = 0
        } else if (sysLocale.startsWith("es")) {
            targetIndex = 2
        } else if (sysLocale.startsWith("zh")) {
            targetIndex = 3
        } else if (sysLocale.startsWith("pt")) {
            if (sysLocale.includes("br")) {
                targetIndex = 5
            } else {
                targetIndex = 4
            }
        }

        currentLang = targetIndex

        // 2. Автоопределение префикса телефона
        if (typeof geoManager !== "undefined" && geoManager.phonePrefix !== "") {
            if (phoneInput.text === "") {
                phoneInput.text = geoManager.phonePrefix + " "
            }
        }
    }

    Connections {
        target: typeof geoManager !== "undefined" ? geoManager : null
        function onPhonePrefixChanged() {
            if (phoneInput.text === "" || phoneInput.text === "+7 " || phoneInput.text === "+ " || phoneInput.text === "+") {
                phoneInput.text = geoManager.phonePrefix + " "
                phoneInput.cursorPosition = phoneInput.text.length
            }
        }
    }

    // ================= 🎨 СТАТИЧНЫЙ ЦВЕТНОЙ ФОН 🎨 =================
    Rectangle {
        anchors.fill: parent
        color: loginScreen.colorBg

        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutQuad } }
    }

    // ================= 🖱️ ЗОНА СНЯТИЯ ФОКУСА 🖱️ =================
    MouseArea {
        anchors.fill: parent
        z: 1
        onClicked: {
            phoneInput.focus = false
        }
    }

    // ================= 🛠️ ПАНЕЛЬ УПРАВЛЕНИЯ ВЕРХУ (ЯЗЫК И ТЕМА) 🛠️ =================
    RowLayout {
        id: topControls
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 16
        anchors.rightMargin: 16
        spacing: 8
        z: 10

        // Кнопка смены темы
        Rectangle {
            id: themeBtn
            width: 36
            height: 36
            radius: 18
            color: themeMouse.containsMouse ? loginScreen.colorBorder : "transparent"
            border.color: themeMouse.containsMouse ? (loginScreen.isDarkTheme ? "#3f3f46" : "#d4d4d8") : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                // Инлайновые SVG иконки Луны и Солнца
                source: loginScreen.isDarkTheme
                    ? "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23fafafa' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z'></path></svg>" // Moon
                    : "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2318181b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><circle cx='12' cy='12' r='5'></circle><line x1='12' y1='1' x2='12' y2='3'></line><line x1='12' y1='21' x2='12' y2='23'></line><line x1='4.22' y1='4.22' x2='5.64' y2='5.64'></line><line x1='18.36' y1='18.36' x2='19.78' y2='19.78'></line><line x1='1' y1='12' x2='3' y2='12'></line><line x1='21' y1='12' x2='23' y2='12'></line><line x1='4.22' y1='19.78' x2='5.64' y2='18.36'></line><line x1='18.36' y1='5.64' x2='19.78' y2='4.22'></line></svg>" // Sun

                rotation: loginScreen.isDarkTheme ? 0 : 360
                Behavior on rotation { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
            }

            MouseArea {
                id: themeMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    loginScreen.isDarkTheme = !loginScreen.isDarkTheme
                }
            }
        }

        // Кнопка смены языка
        Rectangle {
            id: langBtn
            width: 96
            height: 36
            radius: 18
            color: langMouse.containsMouse || langMenu.opened ? loginScreen.colorBorder : "transparent"
            border.color: langMouse.containsMouse || langMenu.opened ? (loginScreen.isDarkTheme ? "#3f3f46" : "#d4d4d8") : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Image {
                    width: 14
                    height: 14
                    Layout.alignment: Qt.AlignVCenter
                    source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='" + (loginScreen.isDarkTheme ? "%23a1a1aa" : "%2371717a") + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><circle cx='12' cy='12' r='10'></circle><line x1='2' y1='12' x2='22' y2='12'></line><path d='M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z'></path></svg>"
                }

                Text {
                    text: loginScreen.translations[loginScreen.currentLang].code
                    color: loginScreen.colorTextMain
                    font.pixelSize: 13
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Image {
                    width: 10
                    height: 10
                    Layout.alignment: Qt.AlignVCenter
                    rotation: langMenu.opened ? 180 : 0
                    source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='" + (loginScreen.isDarkTheme ? "%2371717a" : "%23a1a1aa") + "' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'></polyline></svg>"

                    Behavior on rotation {
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }
                }
            }

            MouseArea {
                id: langMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    langMenu.open()
                }
            }

            Popup {
                id: langMenu
                y: parent.height + 6
                x: parent.width - width
                width: 200
                padding: 6
                modal: false
                focus: true

                enter: Transition {
                    NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
                    NumberAnimation { property: "y"; from: langBtn.height; to: langBtn.height + 6; duration: 150; easing.type: Easing.OutQuad }
                }
                exit: Transition {
                    NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100; easing.type: Easing.InQuad }
                    NumberAnimation { property: "y"; from: langBtn.height + 6; to: langBtn.height; duration: 100; easing.type: Easing.InQuad }
                }

                background: Rectangle {
                    color: loginScreen.colorCardBg
                    border.color: loginScreen.colorBorder
                    border.width: 1
                    radius: 12

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }

                contentItem: ColumnLayout {
                    spacing: 2
                    Repeater {
                        model: loginScreen.translations
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 38
                            radius: 8
                            color: itemMouse.containsMouse ? loginScreen.colorBorder : "transparent"

                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Text {
                                    text: modelData.name
                                    color: loginScreen.currentLang === index ? root.colorPrimary : loginScreen.colorTextMain
                                    font.pixelSize: 13
                                    font.bold: loginScreen.currentLang === index
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight

                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                Image {
                                    width: 12
                                    height: 12
                                    visible: loginScreen.currentLang === index
                                    Layout.alignment: Qt.AlignVCenter
                                    source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23ea580c' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'><polyline points='20 6 9 17 4 12'></polyline></svg>"
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    loginScreen.currentLang = index
                                    langMenu.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ================= 📱 ФОРМА ВХОДА 📱 =================
    ColumnLayout {
        id: formContainer
        anchors.centerIn: parent
        width: 360
        spacing: 24
        z: 5

        // Бесшовный анимированный векторный логотип (Infinity Loop в виде inline SVG)
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 110

            Image {
                id: logoImage
                anchors.centerIn: parent
                width: 130
                height: 65
                fillMode: Image.PreserveAspectFit

                // Встроенная SVG-графика с градиентом (не требует внешних файлов и путей)
                source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 50' width='100' height='50'><defs><linearGradient id='grad' x1='0%' y1='0%' x2='100%' y2='100%'><stop offset='0%' style='stop-color:%23EA580C;stop-opacity:1' /><stop offset='100%' style='stop-color:%236366F1;stop-opacity:1' /></linearGradient></defs><path d='M25,41 C13,41 4,32 4,20 C4,8 13,0 25,0 C32,0 39,4 43,10 L57,30 C61,36 68,40 75,40 C87,40 96,32 96,20 C96,8 87,0 75,0 C68,0 61,4 57,10 L43,30 C39,36 32,41 25,41 Z' fill='none' stroke='url(%23grad)' stroke-width='8' stroke-linejoin='round' stroke-linecap='round'/></svg>"

                opacity: 0
                scale: 0.85

                // Плавная анимация появления на старте
                ParallelAnimation {
                    running: true
                    NumberAnimation { target: logoImage; property: "opacity"; to: 1.0; duration: 900; easing.type: Easing.OutCubic }
                    NumberAnimation { target: logoImage; property: "scale"; to: 1.0; duration: 1100; easing.type: Easing.OutBack }
                }

                transform: Translate {
                    id: logoTranslate
                    y: 0
                }

                // Плавное парение (микро-левитация) без перезапуска слоев верстки
                SequentialAnimation {
                    running: logoImage.opacity === 1.0
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: logoTranslate
                        property: "y"
                        to: -5
                        duration: 2200
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: logoTranslate
                        property: "y"
                        to: 5
                        duration: 2200
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        // Заголовки
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: loginScreen.textWelcome
                color: loginScreen.colorTextMain
                font.pixelSize: 32
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter

                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                text: loginScreen.textSub
                color: loginScreen.colorTextSub
                font.pixelSize: 15
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        // Поле ввода номера телефона
        Rectangle {
            id: inputFieldBg
            Layout.fillWidth: true
            height: 54
            radius: 12
            color: loginScreen.colorInputBg
            border.color: phoneInput.activeFocus ? "transparent" : loginScreen.colorBorder
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            // Акцентная рамка при фокусе
            Rectangle {
                anchors.fill: parent
                radius: 12
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.colorPrimary }
                    GradientStop { position: 0.3; color: root.colorPrimary }
                    GradientStop { position: 0.7; color: "#EA580C" }
                    GradientStop { position: 1.0; color: "#EA580C" }
                }
                opacity: phoneInput.activeFocus ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: phoneInput.activeFocus ? 2 : 0
                radius: phoneInput.activeFocus ? 11 : 12
                color: loginScreen.colorInputBg

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Image {
                        width: 16
                        height: 16
                        Layout.alignment: Qt.AlignVCenter
                        opacity: phoneInput.activeFocus ? 1.0 : 0.6
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='" + (loginScreen.isDarkTheme ? "%23a1a1aa" : "%2371717a") + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z'></path></svg>"
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    TextField {
                        id: phoneInput
                        Layout.fillWidth: true
                        color: loginScreen.colorTextMain
                        font.pixelSize: 16
                        placeholderText: loginScreen.textPhonePlaceholder
                        placeholderTextColor: loginScreen.isDarkTheme ? "#52525b" : "#a1a1aa"
                        cursorVisible: true
                        inputMethodHints: Qt.ImhDialableCharactersOnly
                        background: Item {}
                        validator: RegularExpressionValidator { regularExpression: /^\+?[\d\s]*$/ }
                        maximumLength: 20

                        Behavior on color { ColorAnimation { duration: 150 } }

                        onTextEdited: {
                            let rawCursor = cursorPosition
                            let textBeforeCursor = text.substring(0, rawCursor)

                            let validCharsBefore = textBeforeCursor.replace(/[^\d\+]/g, "").length
                            let cleanText = text.replace(/[^\d\+]/g, "")

                            if (cleanText.length > 0 && !cleanText.startsWith("+")) {
                                if (cleanText.startsWith("8")) {
                                    cleanText = "+7" + cleanText.substring(1)
                                    if (validCharsBefore > 0) validCharsBefore += 1
                                } else if (cleanText.startsWith("9") && cleanText.length === 1) {
                                    cleanText = "+79"
                                    validCharsBefore += 2
                                } else {
                                    cleanText = "+" + cleanText
                                    validCharsBefore += 1
                                }
                            }

                            if (cleanText.length > 1) {
                                cleanText = "+" + cleanText.substring(1).replace(/\+/g, "")
                            }

                            let isRU = cleanText.startsWith("+7")
                            let digitsOnly = cleanText.replace(/\D/g, "")

                            let maxDigits = isRU ? 11 : 15
                            if (digitsOnly.length > maxDigits) {
                                digitsOnly = digitsOnly.substring(0, maxDigits)
                            }

                            let formatted = cleanText.length > 0 ? "+" : ""

                            if (digitsOnly.length > 0) {
                                if (isRU) {
                                    for (let i = 0; i < digitsOnly.length; i++) {
                                        if (i === 1 || i === 4 || i === 7 || i === 9) formatted += " "
                                        formatted += digitsOnly[i]
                                    }
                                } else {
                                    for (let i = 0; i < digitsOnly.length; i++) {
                                        if (i === 1 || i === 4 || i === 8 || i === 12) formatted += " "
                                        formatted += digitsOnly[i]
                                    }
                                }
                            }

                            if (text !== formatted) {
                                text = formatted
                                let newPos = 0
                                let validPassed = 0
                                while (newPos < text.length && validPassed < validCharsBefore) {
                                    if (text[newPos] === '+' || /\d/.test(text[newPos])) {
                                        validPassed++
                                    }
                                    newPos++
                                }
                                cursorPosition = newPos
                            }
                        }

                        onActiveFocusChanged: {
                            if (activeFocus) {
                                Qt.callLater(() => cursorPosition = text.length)
                            }
                        }
                    }
                }
            }
        }

        // Кнопка «Продолжить»
        Button {
            id: continueBtn
            Layout.fillWidth: true
            implicitHeight: 50

            enabled: {
                let digitsCount = phoneInput.text.replace(/\D/g, "").length
                let isRU = phoneInput.text.replace(/\D/g, "").startsWith("7")
                return isRU ? digitsCount >= 11 : digitsCount >= 10
            }

            contentItem: Text {
                text: loginScreen.textContinue
                color: continueBtn.enabled ? "#ffffff" : "#71717a"
                font.pixelSize: 16
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 12
                color: continueBtn.enabled
                       ? (continueBtn.pressed ? Qt.darker(root.colorPrimary, 1.1) : root.colorPrimary)
                       : (loginScreen.isDarkTheme ? "#27272a" : "#e4e4e7")
                opacity: continueBtn.enabled ? 1.0 : 0.6

                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            onClicked: loginScreen.loginSuccessful()
        }

        // Разделитель «или»
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: loginScreen.colorBorder
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                text: loginScreen.textOr
                color: loginScreen.colorTextSub
                font.pixelSize: 13
                font.bold: false
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: loginScreen.colorBorder
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        // Новая кнопка «Войти по QR-коду»
        Button {
            id: qrBtn
            Layout.fillWidth: true
            implicitHeight: 50

            contentItem: RowLayout {
                spacing: 8
                anchors.centerIn: parent

                Image {
                    width: 18
                    height: 18
                    Layout.alignment: Qt.AlignVCenter
                    source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='" + (loginScreen.isDarkTheme ? "%23fafafa" : "%2318181b") + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><rect x='3' y='3' width='7' height='7'></rect><rect x='14' y='3' width='7' height='7'></rect><rect x='14' y='14' width='7' height='7'></rect><rect x='3' y='14' width='7' height='7'></rect><line x1='7' y1='7' x2='7.01' y2='7'></line><line x1='17' y1='7' x2='17.01' y2='7'></line><line x1='17' y1='17' x2='17.01' y2='17'></line><line x1='7' y1='17' x2='7.01' y2='17'></line></svg>"
                }

                Text {
                    text: loginScreen.textQr
                    color: loginScreen.colorTextMain
                    font.pixelSize: 15
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            background: Rectangle {
                radius: 12
                color: qrBtn.pressed ? loginScreen.colorBorder : "transparent"
                border.color: loginScreen.colorBorder
                border.width: 1

                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            onClicked: loginScreen.qrLoginRequested()
        }
    }
}
