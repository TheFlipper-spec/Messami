#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <vector>
#include "messagemodel.h" // Подключаем, чтобы видеть структуру Message

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    bool initDatabase();
    bool saveMessage(const Message &msg);
    std::vector<Message> loadChatHistory();

private:
    QSqlDatabase m_db;
};
