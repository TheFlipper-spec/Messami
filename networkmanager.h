#pragma once

#include <QObject>
#include <QWebSocket> // Используем WebSockets вместо TCP
#include <QString>

class NetworkManager : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = nullptr);

    // Подключение теперь требует URL (например, ws://localhost:8080/ws)
    void connectToServer(const QString &url);

    // Отправка текстового сообщения в чат (внутри упакуем в JSON)
    void sendChatMessage(const QString &senderName, const QString &text);

signals:
    void connected();
    void disconnected();

    // Вместо сырой строки отдаем готовые данные для MessageModel
    void chatMessageReceived(const QString &sender, const QString &text, qint64 timestamp);

private slots:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(const QString &message); // Ловим текстовые фреймы (JSON)
    void onErrorOccurred(QAbstractSocket::SocketError error);

private:
    QWebSocket m_webSocket; // Наш WebSocket клиент
};
