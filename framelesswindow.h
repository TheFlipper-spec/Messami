#pragma once

#include <QAbstractNativeEventFilter>

class QQuickWindow;

class FramelessWindow : public QAbstractNativeEventFilter
{
public:
    void setup(QQuickWindow *window);
    bool nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result) override;

private:
    QQuickWindow *m_window = nullptr;
};
