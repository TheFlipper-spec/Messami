#include "messengercore.h"
#include <QDebug>
#include <QUuid>
#include <QDateTime>

MessengerCore::MessengerCore(QObject *parent)
    : QObject{parent}, m_connectionStatus("Подключение...")
{
    m_chatModel = new MessageModel(this);
    m_networkManager = new NetworkManager(this);
    m_dbManager = new DatabaseManager(this);

    // Загрузка истории из локальной БД при старте приложения
    if (m_dbManager->initDatabase()) {
        std::vector<Message> history = m_dbManager->loadChatHistory();
        m_chatModel->loadHistory(history);
    }

    // Обработка статусов подключения (сигналы от NetworkManager)
    connect(m_networkManager, &NetworkManager::connected, this, [this]() {
        m_connectionStatus = "Online";
        emit connectionStatusChanged();
    });

    connect(m_networkManager, &NetworkManager::disconnected, this, [this]() {
        m_connectionStatus = "Offline";
        emit connectionStatusChanged();
    });

    // Обработка ВХОДЯЩИХ сообщений (теперь мы получаем распарсенные данные из JSON)
    connect(m_networkManager, &NetworkManager::chatMessageReceived, this, [this](const QString &sender, const QString &text, qint64 timestamp) {

        // ВАЖНО: Защита от дубликатов (Эхо)
        // Так как мы добавляем свои сообщения в UI сразу при отправке (Оптимистичный UI),
        // а сервер рассылает сообщение ВСЕМ (включая нас самих), нам нужно игнорировать
        // свои же сообщения, вернувшиеся от сервера.
        if (sender == "Я") {
            return;
        }

        Message msg;
        msg.id = QUuid::createUuid().toString();
        msg.senderName = sender; // Имя берем то, которое прислал сервер
        msg.text = text;
        // Конвертируем Unix Timestamp (секунды), пришедший от Go-сервера, в QDateTime
        msg.timestamp = QDateTime::fromSecsSinceEpoch(timestamp);
        msg.isMine = false; // Раз прошло проверку выше, значит отправитель точно не мы
        msg.isRead = false;

        m_chatModel->addMessage(msg);
        m_dbManager->saveMessage(msg); // Сохраняем входящее сообщение в БД
    });

    // Подключаемся к нашему локальному Go-серверу по WebSocket
    m_networkManager->connectToServer("ws://localhost:8080/ws");
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
    msg.senderName = "Я"; // Хардкодим имя отправителя (потом можно брать из настроек профиля)
    msg.text = text;
    msg.timestamp = QDateTime::currentDateTime();
    msg.isMine = true;
    msg.isRead = false;

    // Оптимистичный UI: мгновенно показываем сообщение в интерфейсе и пишем в БД
    m_chatModel->addMessage(msg);
    m_dbManager->saveMessage(msg);

    // Отправляем на сервер (NetworkManager сам создаст JSON {"type":"chat", "sender":"Я", "content":"text"})
    m_networkManager->sendChatMessage("Я", text);
}
