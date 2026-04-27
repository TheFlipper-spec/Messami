#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>
#include "networkmanager.h"
#include "messagemodel.h" // Подключаем нашу модель

class MessengerCore : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString connectionStatus READ connectionStatus NOTIFY connectionStatusChanged)
    // Свойство для передачи Модели в QML
    Q_PROPERTY(MessageModel* chatModel READ chatModel CONSTANT)

public:
    explicit MessengerCore(QObject *parent = nullptr);

    QString connectionStatus() const;
    MessageModel* chatModel() const; // Геттер модели

    Q_INVOKABLE void sendMessage(const QString &text);

signals:
    void connectionStatusChanged();

private:
    QString m_connectionStatus;
    NetworkManager *m_networkManager;
    MessageModel *m_chatModel; // Указатель на модель
};
