#include "geomanager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QNetworkRequest>

GeoManager::GeoManager(QObject *parent)
    : QObject(parent), m_countryCode("RU"), m_phonePrefix("+7") // Дефолтные значения
{
    m_networkManager = new QNetworkAccessManager(this);
    connect(m_networkManager, &QNetworkAccessManager::finished, this, &GeoManager::onReplyFinished);
}

void GeoManager::detectLocation()
{
    // Отличный API, который работает по HTTPS и отдает calling_code
    QNetworkRequest request(QUrl("https://ipwho.is/"));
    // Добавляем User-Agent, чтобы сервер не блокировал запрос
    request.setHeader(QNetworkRequest::UserAgentHeader, "MessamiApp/1.0");
    m_networkManager->get(request);
}

QString GeoManager::countryCode() const { return m_countryCode; }
QString GeoManager::phonePrefix() const { return m_phonePrefix; }

void GeoManager::onReplyFinished(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError) {
        QByteArray responseData = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData);
        QJsonObject jsonObj = jsonDoc.object();

        // Проверяем, успешен ли ответ
        if (jsonObj.contains("success") && jsonObj["success"].toBool() == true) {
            // Получаем код страны (например, "RU", "GE", "US")
            m_countryCode = jsonObj["country_code"].toString();

            // Получаем телефонный код напрямую от API (например, "7", "995", "1")
            // и добавляем к нему плюс спереди
            m_phonePrefix = "+" + jsonObj["calling_code"].toString();

            emit countryCodeChanged();
            emit phonePrefixChanged();
        }
    } else {
        qDebug() << "Ошибка получения геолокации:" << reply->errorString();
    }
    reply->deleteLater();
}
