#ifndef GEOMANAGER_H
#define GEOMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class GeoManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString countryCode READ countryCode NOTIFY countryCodeChanged)
    Q_PROPERTY(QString phonePrefix READ phonePrefix NOTIFY phonePrefixChanged)

public:
    explicit GeoManager(QObject *parent = nullptr);

    Q_INVOKABLE void detectLocation();

    QString countryCode() const;
    QString phonePrefix() const;

signals:
    void countryCodeChanged();
    void phonePrefixChanged();

private slots:
    void onReplyFinished(QNetworkReply *reply);

private:
    QNetworkAccessManager *m_networkManager;
    QString m_countryCode;
    QString m_phonePrefix;
};

#endif // GEOMANAGER_H
