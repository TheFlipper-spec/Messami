#include "networkmanager.h"
#include <QDebug>

NetworkManager::NetworkManager(QObject *parent)
    : QObject{parent}
{
    // Связываем сигналы сокета с нашими методами
    connect(&m_socket, &QTcpSocket::connected, this, &NetworkManager::onConnected);
    connect(&m_socket, &QTcpSocket::disconnected, this, &NetworkManager::disconnected);
    connect(&m_socket, &QTcpSocket::readyRead, this, &NetworkManager::onReadyRead);
    connect(&m_socket, &QTcpSocket::errorOccurred, this, &NetworkManager::onErrorOccurred);
}

void NetworkManager::connectToServer(const QString &host, quint16 port)
{
    qDebug() << "[TCP СЕТЬ] Подключение к:" << host << ":" << port;
    m_socket.connectToHost(host, port);
}

void NetworkManager::sendMessage(const QString &message)
{
    if (m_socket.state() == QAbstractSocket::ConnectedState) {
        // Превращаем текст в байты и добавляем перенос строки (нужно для эхо-сервера)
        QByteArray data = message.toUtf8() + "\n";
        m_socket.write(data);
        m_socket.flush(); // Выталкиваем данные в сеть мгновенно
    }
}

void NetworkManager::onConnected()
{
    qDebug() << "[TCP СЕТЬ] Соединение установлено!";
    emit connected();
}

void NetworkManager::onReadyRead()
{
    // Читаем все байты, которые пришли из интернета
    QByteArray data = m_socket.readAll();

    // Превращаем обратно в текст
    QString text = QString::fromUtf8(data).trimmed();

    if (!text.isEmpty()) {
        emit messageReceived(text);
    }
}

void NetworkManager::onErrorOccurred(QAbstractSocket::SocketError error)
{
    qDebug() << "[TCP СЕТЬ] ОШИБКА:" << m_socket.errorString();
}
