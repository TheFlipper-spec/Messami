#include "networkmanager.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

NetworkManager::NetworkManager(QObject *parent)
    : QObject{parent}
{
    // Подписываемся на события WebSocket
    connect(&m_webSocket, &QWebSocket::connected, this, &NetworkManager::onConnected);
    connect(&m_webSocket, &QWebSocket::disconnected, this, &NetworkManager::onDisconnected);
    connect(&m_webSocket, &QWebSocket::textMessageReceived, this, &NetworkManager::onTextMessageReceived);
    connect(&m_webSocket, &QWebSocket::errorOccurred, this, &NetworkManager::onErrorOccurred);
}

void NetworkManager::connectToServer(const QString &url)
{
    qDebug() << "[WS СЕТЬ] Подключение к:" << url;
    // Открываем соединение. QUrl сам разберет строку вида "ws://localhost:8080/ws"
    m_webSocket.open(QUrl(url));
}

void NetworkManager::sendChatMessage(const QString &senderName, const QString &text)
{
    if (m_webSocket.state() == QAbstractSocket::ConnectedState) {
        // 1. Создаем JSON объект
        QJsonObject jsonObj;
        jsonObj["type"] = "chat";
        jsonObj["sender"] = senderName;
        jsonObj["content"] = text;

        // 2. Упаковываем объект в JSON документ
        QJsonDocument doc(jsonObj);

        // 3. Превращаем в строку (Compact означает без лишних пробелов и переносов)
        QString jsonString = QString::fromUtf8(doc.toJson(QJsonDocument::Compact));

        // 4. Отправляем на сервер
        m_webSocket.sendTextMessage(jsonString);
    } else {
        qWarning() << "[WS СЕТЬ] Попытка отправить сообщение, но нет подключения!";
    }
}

void NetworkManager::onConnected()
{
    qDebug() << "[WS СЕТЬ] Соединение установлено!";
    emit connected();
}

void NetworkManager::onDisconnected()
{
    qDebug() << "[WS СЕТЬ] Соединение разорвано!";
    emit disconnected();
}

void NetworkManager::onTextMessageReceived(const QString &message)
{
    // Сюда прилетают строки от Go-сервера. Мы ожидаем JSON.
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8());

    // Проверяем, что пришел валидный JSON объект
    if (doc.isNull() || !doc.isObject()) {
        qWarning() << "[WS СЕТЬ] Получен невалидный JSON:" << message;
        return;
    }

    QJsonObject jsonObj = doc.object();

    // Роутинг сообщений в зависимости от типа (type)
    QString type = jsonObj["type"].toString();

    if (type == "chat") {
        QString sender = jsonObj["sender"].toString();
        QString content = jsonObj["content"].toString();
        // Сервер отдает время в секундах (Unix time)
        qint64 timestamp = jsonObj["timestamp"].toVariant().toLongLong();

        qDebug() << "[WS СЕТЬ] Входящее сообщение от" << sender << ":" << content;

        // Отдаем данные наружу (в MessengerCore, который передаст их в MessageModel)
        emit chatMessageReceived(sender, content, timestamp);
    }
    // Здесь в будущем можно добавить обработку {"type": "auth_success"}, {"type": "user_typing"} и т.д.
}

void NetworkManager::onErrorOccurred(QAbstractSocket::SocketError error)
{
    qDebug() << "[WS СЕТЬ] ОШИБКА:" << m_webSocket.errorString();
}
