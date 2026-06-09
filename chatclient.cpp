#include "chatclient.h"
#include <QDebug>

ChatClient::ChatClient(const QUrl &serverUrl, QObject *parent) :
    QObject(parent),
    m_url(serverUrl),
    m_retryCount(0)
{
    connect(&m_webSocket, &QWebSocket::connected, this, &ChatClient::onConnected);
    connect(&m_webSocket, &QWebSocket::disconnected, this, &ChatClient::onDisconnected);
    connect(&m_webSocket, QOverload<QAbstractSocket::SocketError>::of(&QWebSocket::errorOccurred),
            this, &ChatClient::onError);

    // ВАЖНО: Слушаем бинарные сообщения, так как у нас Protobuf!
    connect(&m_webSocket, &QWebSocket::binaryMessageReceived,
            this, &ChatClient::onBinaryMessageReceived);

    connect(&m_reconnectTimer, &QTimer::timeout, this, &ChatClient::reconnect);
}

void ChatClient::connectToServer()
{
    qDebug() << "Connecting to" << m_url.toString();
    m_webSocket.open(m_url);
}

void ChatClient::sendMessage(const QByteArray &binaryData)
{
    if (m_webSocket.state() == QAbstractSocket::ConnectedState) {
        m_webSocket.sendBinaryMessage(binaryData);
    } else {
        qWarning() << "Socket is not connected. Cannot send message.";
        // В продакшене тут нужно сохранять сообщение в локальную БД (SQLite)
        // для отправки после восстановления связи.
    }
}

void ChatClient::onConnected()
{
    qDebug() << "WebSocket connected";
    m_reconnectTimer.stop();
    m_retryCount = 0;
    emit connected();

    // Здесь отправляем сообщение авторизации AuthRequest (Protobuf)
}

void ChatClient::onDisconnected()
{
    qDebug() << "WebSocket disconnected";
    emit disconnected();

    // Экспоненциальная задержка переподключения
    int delay = qMin(1000 * (1 << m_retryCount), 30000);
    qDebug() << "Reconnecting in" << delay << "ms...";
    m_reconnectTimer.start(delay);
    m_retryCount++;
}

void ChatClient::onBinaryMessageReceived(const QByteArray &message)
{
    // Сюда приходят байты.
    // Дальше в бизнес-логике ты передашь это в Protobuf парсер:
    // pb::Envelope envelope; envelope.ParseFromArray(message.data(), message.size());
    emit messageReceived(message);
}

void ChatClient::onError(QAbstractSocket::SocketError error)
{
    qWarning() << "WebSocket error:" << error << m_webSocket.errorString();
}

void ChatClient::reconnect()
{
    m_reconnectTimer.stop();
    connectToServer();
}
