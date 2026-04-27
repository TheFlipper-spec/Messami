#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QIcon>
#include <QString>
#include <QList>
#include <QSystemTrayIcon>
#include <QMenu>
#include <QAction>

#include "framelesswindow.h"

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QApplication::setQuitOnLastWindowClosed(false);

    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(u":/Messami/app_icon.ico"_s));

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/Messami/Main.qml"_s);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    engine.load(url);

    const QList<QObject *> rootObjects = engine.rootObjects();

    if (rootObjects.isEmpty()) {
        return -1;
    }

    QQuickWindow *window = qobject_cast<QQuickWindow *>(rootObjects.at(0));

    QSystemTrayIcon *trayIcon = new QSystemTrayIcon(QIcon(u":/Messami/app_icon.ico"_s), &app);
    trayIcon->setToolTip(u"Messami"_s);

    QMenu *trayMenu = new QMenu();

    QAction *showAction = trayMenu->addAction(u"Открыть Messami"_s);
    trayMenu->addSeparator();
    QAction *quitAction = trayMenu->addAction(u"Выйти"_s);

    trayIcon->setContextMenu(trayMenu);

    QObject::connect(trayIcon, &QSystemTrayIcon::activated,
                     [window](QSystemTrayIcon::ActivationReason reason) {
                         if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::DoubleClick) {
                             if (window) {
                                 window->show();
                                 window->raise();
                                 window->requestActivate();
                             }
                         }
                     });

    QObject::connect(showAction, &QAction::triggered, [window]() {
        if (window) {
            window->show();
            window->raise();
            window->requestActivate();
        }
    });

    QObject::connect(quitAction, &QAction::triggered, &app, &QCoreApplication::quit);

    trayIcon->show();

    if (window) {
        static FramelessWindow framelessHelper;
        framelessHelper.setup(window);
        window->show();
    }

    return app.exec();
}
