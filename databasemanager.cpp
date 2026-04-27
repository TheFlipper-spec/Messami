#include "databasemanager.h"
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QVariant>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::initDatabase()
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");

    // Папка AppData/Roaming/НазваниеКомпании/НазваниеПроекта
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataDir);

    QString dbPath = dataDir + "/messami.db";
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qCritical() << "Ошибка БД:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery query;
    // Создаем таблицу, учитывая все поля вашей структуры Message
    QString createTable =
        "CREATE TABLE IF NOT EXISTS messages ("
        "id TEXT PRIMARY KEY, "
        "senderName TEXT, "
        "text TEXT, "
        "timestamp TEXT, "
        "isMine INTEGER, "
        "isRead INTEGER)";

    if (!query.exec(createTable)) {
        qCritical() << "Ошибка создания таблицы:" << query.lastError().text();
        return false;
    }

    qDebug() << "БД загружена:" << dbPath;
    return true;
}

bool DatabaseManager::saveMessage(const Message &msg)
{
    if (!m_db.isOpen()) return false;

    QSqlQuery query;
    query.prepare("INSERT INTO messages (id, senderName, text, timestamp, isMine, isRead) "
                  "VALUES (:id, :sender, :text, :time, :mine, :read)");

    query.bindValue(":id", msg.id);
    query.bindValue(":sender", msg.senderName);
    query.bindValue(":text", msg.text);
    // Сохраняем время в универсальном формате ISO
    query.bindValue(":time", msg.timestamp.toString(Qt::ISODate));
    // SQLite не имеет типа bool, сохраняем как 0 или 1
    query.bindValue(":mine", msg.isMine ? 1 : 0);
    query.bindValue(":read", msg.isRead ? 1 : 0);

    if (!query.exec()) {
        qCritical() << "Ошибка сохранения:" << query.lastError().text();
        return false;
    }
    return true;
}

std::vector<Message> DatabaseManager::loadChatHistory()
{
    std::vector<Message> history;
    if (!m_db.isOpen()) return history;

    // Сортируем по времени (старые сверху)
    QSqlQuery query("SELECT id, senderName, text, timestamp, isMine, isRead FROM messages ORDER BY timestamp ASC");

    while (query.next()) {
        Message msg;
        msg.id = query.value(0).toString();
        msg.senderName = query.value(1).toString();
        msg.text = query.value(2).toString();
        msg.timestamp = QDateTime::fromString(query.value(3).toString(), Qt::ISODate);
        msg.isMine = query.value(4).toInt() != 0;
        msg.isRead = query.value(5).toInt() != 0;

        history.push_back(msg);
    }
    return history;
}
