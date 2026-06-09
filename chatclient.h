#ifndef CHATCLIENT_H
#define CHATCLIENT_H

#include <QObject>
#include <QtWebSockets/QWebSocket>
#include <QTimer>
#include <QUrl>

class ChatClient : public QObject
{
Q_OBJECT
    public:
             explicit ChatClient(const QUrl &serverUrl, QObject *parent = nullptr);
    void connectToServer();
    void sendMessage(const QByteArray &binaryData); // Отправляем Protobuf

signals:
    void messageReceived(const QByteArray &data);
    void connected();
    void disconnected();

private slots:
    void onConnected();
    void onDisconnected();
    void onBinaryMessageReceived(const QByteArray &message);
    void onError(QAbstractSocket::SocketError error);
    void reconnect();

private:
    QWebSocket m_webSocket;
    QUrl m_url;
    QTimer m_reconnectTimer;
    int m_retryCount;
};

#endif // CHATCLIENT_H
