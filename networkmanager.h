#pragma once

#include <QObject>
#include <QTcpSocket>
#include <QString>

class NetworkManager : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = nullptr);

    // Подключение по IP/домену и порту (как в Telegram)
    void connectToServer(const QString &host, quint16 port);
    void sendMessage(const QString &message);

signals:
    void connected();
    void disconnected();
    void messageReceived(const QString &message);

private slots:
    void onConnected();
    void onReadyRead(); // Этот слот читает сырые байты TCP
    void onErrorOccurred(QAbstractSocket::SocketError error);

private:
    QTcpSocket m_socket; // Наш быстрый TCP сокет
};
