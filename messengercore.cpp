#include "messengercore.h"
#include <QDebug>
#include <QUuid>
#include <QDateTime>

MessengerCore::MessengerCore(QObject *parent)
    : QObject{parent}, m_connectionStatus("Подключение...")
{
    m_chatModel = new MessageModel(this);
    m_networkManager = new NetworkManager(this);

    connect(m_networkManager, &NetworkManager::connected, this, [this]() {
        m_connectionStatus = "Online";
        emit connectionStatusChanged();
    });

    connect(m_networkManager, &NetworkManager::disconnected, this, [this]() {
        m_connectionStatus = "Offline";
        emit connectionStatusChanged();
    });

    connect(m_networkManager, &NetworkManager::messageReceived, this, [this](const QString &text) {
        Message msg;
        msg.id = QUuid::createUuid().toString();
        msg.senderName = "Собеседник";
        msg.text = text;
        msg.timestamp = QDateTime::currentDateTime();
        msg.isMine = false;
        msg.isRead = false;

        m_chatModel->addMessage(msg);
    });

    // ВНИМАНИЕ: Новое подключение по TCP!
    m_networkManager->connectToServer("tcpbin.com", 4242);
}

QString MessengerCore::connectionStatus() const
{
    return m_connectionStatus;
}

MessageModel* MessengerCore::chatModel() const
{
    return m_chatModel;
}

void MessengerCore::sendMessage(const QString &text)
{
    if (text.trimmed().isEmpty()) return;

    Message msg;
    msg.id = QUuid::createUuid().toString();
    msg.senderName = "Я";
    msg.text = text;
    msg.timestamp = QDateTime::currentDateTime();
    msg.isMine = true;
    msg.isRead = false;

    m_chatModel->addMessage(msg);

    m_networkManager->sendMessage(text);
}
