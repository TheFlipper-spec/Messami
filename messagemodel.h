#pragma once

#include <QAbstractListModel>
#include <vector>
#include <QString>
#include <QDateTime>

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

    enum MessageRoles {
        IdRole = Qt::UserRole + 1,
        SenderNameRole,
        TextRole,
        TimestampRole,
        IsMineRole,
        IsReadRole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addMessage(const Message &msg);
    void clear();
    void loadHistory(const std::vector<Message> &history); // <--- ДОБАВЛЕНО

private:
    std::vector<Message> m_messages;
};
