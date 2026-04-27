#pragma once

#include <QAbstractListModel>
#include <vector>
#include <QString>
#include <QDateTime>

// Легкая C++ структура для одного сообщения (без QObject, для скорости)
struct Message {
    QString id;
    QString senderName;
    QString text;
    QDateTime timestamp;
    bool isMine;
    bool isRead;
};

class MessageModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit MessageModel(QObject *parent = nullptr);

    // Ключи, по которым QML будет запрашивать данные
    enum MessageRoles {
        IdRole = Qt::UserRole + 1,
        SenderNameRole,
        TextRole,
        TimestampRole,
        IsMineRole,
        IsReadRole
    };

    // Обязательные методы QAbstractListModel
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Наши методы управления
    void addMessage(const Message &msg);
    void clear();

private:
    std::vector<Message> m_messages; // std::vector работает быстрее QList
};
