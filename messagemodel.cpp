#include "messagemodel.h"

MessageModel::MessageModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int MessageModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return static_cast<int>(m_messages.size());
}

QVariant MessageModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return QVariant();
    if (index.row() >= static_cast<int>(m_messages.size())) return QVariant();

    const Message &msg = m_messages.at(index.row());

    // Отдаем QML конкретное поле за O(1)
    switch (role) {
    case IdRole:         return msg.id;
    case SenderNameRole: return msg.senderName;
    case TextRole:       return msg.text;
    case TimestampRole:  return msg.timestamp.toString("hh:mm"); // Форматируем время для UI
    case IsMineRole:     return msg.isMine;
    case IsReadRole:     return msg.isRead;
    default:             return QVariant();
    }
}

QHash<int, QByteArray> MessageModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole]         = "messageId";
    roles[SenderNameRole] = "senderName";
    roles[TextRole]       = "messageText";
    roles[TimestampRole]  = "timestamp";
    roles[IsMineRole]     = "isMine";
    roles[IsReadRole]     = "isRead";
    return roles;
}

void MessageModel::addMessage(const Message &msg)
{
    // Предупреждаем QML о новых данных, чтобы он плавно отрисовал их без фризов
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_messages.push_back(msg);
    endInsertRows();
}

void MessageModel::clear()
{
    beginResetModel();
    m_messages.clear();
    endResetModel();
}
