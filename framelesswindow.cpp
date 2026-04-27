#include "framelesswindow.h"
#include <QQuickWindow>
#include <QGuiApplication>

#ifdef Q_OS_WIN
#include <windows.h>
#include <dwmapi.h>
#include <windowsx.h>
#endif

void FramelessWindow::setup(QQuickWindow *window)
{
    m_window = window;

#ifdef Q_OS_WIN
    // Принудительно создаём нативное окно Windows (HWND)
    window->create();
    HWND hwnd = reinterpret_cast<HWND>(window->winId());

    // Устанавливаем перехватчик системных сообщений ДО показа окна
    qApp->installNativeEventFilter(this);

    // ГЛАВНЫЙ СЕКРЕТ: Мы НЕ убираем WS_CAPTION!
    // Наоборот, мы ДОБАВЛЯЕМ все стили "нормального окна".
    // Windows видит эти флаги и думает: "Это обычное окно, даю ему анимации!"
    // А наш обработчик WM_NCCALCSIZE скажет: "Высота заголовка = 0 пикселей"
    DWORD style = GetWindowLongW(hwnd, GWL_STYLE);
    style |= WS_THICKFRAME    // Рамка для ресайза + анимации сворачивания/разворачивания
             | WS_CAPTION        // ОСТАВЛЯЕМ! Без этого Windows не даст анимации
             | WS_SYSMENU        // Системное меню (Alt+F4, и т.д.)
             | WS_MINIMIZEBOX    // Кнопка свернуть (анимация сворачивания в таскбар)
             | WS_MAXIMIZEBOX;   // Кнопка развернуть (анимация на весь экран + Aero Snap)
    SetWindowLongW(hwnd, GWL_STYLE, style);

    // Расширяем рамку DWM на 1 пиксель сверху.
    // Это даёт нам нативную ТЕНЬ вокруг окна (как у Telegram Desktop)
    MARGINS margins = {0, 0, 1, 0};
    DwmExtendFrameIntoClientArea(hwnd, &margins);

    // Заставляем Windows пересчитать рамку.
    // Это вызовет WM_NCCALCSIZE, который мы перехватываем ниже.
    SetWindowPos(hwnd, nullptr, 0, 0, 0, 0,
                 SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
#endif
}

bool FramelessWindow::nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result)
{
#ifdef Q_OS_WIN
    if (!m_window) return false;
    if (eventType != "windows_generic_MSG") return false;

    MSG *msg = static_cast<MSG *>(message);
    HWND hwnd = reinterpret_cast<HWND>(m_window->winId());
    if (msg->hwnd != hwnd) return false;

    switch (msg->message) {

    // =====================================================
    // WM_NCCALCSIZE: Windows спрашивает "какого размера заголовок?"
    // Мы отвечаем: "0 пикселей! Вся площадь окна — наша!"
    // При этом WS_CAPTION всё ещё стоит, поэтому анимации работают.
    // =====================================================
    case WM_NCCALCSIZE: {
        if (msg->wParam == TRUE) {
            // Когда окно развёрнуто на весь экран, нужно учитывать таскбар,
            // иначе наше окно залезет ПОД панель задач Windows
            if (IsZoomed(hwnd)) {
                NCCALCSIZE_PARAMS *params = reinterpret_cast<NCCALCSIZE_PARAMS *>(msg->lParam);
                HMONITOR mon = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
                MONITORINFO mi;
                mi.cbSize = sizeof(mi);
                if (GetMonitorInfoW(mon, &mi)) {
                    params->rgrc[0] = mi.rcWork; // Область экрана БЕЗ таскбара
                }
            }
            // Возвращаем 0 = "Не вырезай ничего из окна, всё пространство — клиентская область"
            *result = 0;
            return true;
        }
        break;
    }

    // =====================================================
    // WM_NCHITTEST: Windows спрашивает "Курсор над какой частью окна?"
    // Мы отвечаем: если курсор у самого края — это зона ресайза.
    // В остальных случаях пропускаем обработку в QML (return false).
    // =====================================================
    case WM_NCHITTEST: {
        RECT winRect;
        GetWindowRect(hwnd, &winRect);

        int x = GET_X_LPARAM(msg->lParam); // Координата X курсора мыши на экране
        int y = GET_Y_LPARAM(msg->lParam); // Координата Y курсора мыши на экране

        // Учитываем масштабирование Windows (125%, 150%, 200%)
        double dpr = m_window->devicePixelRatio();
        int border = static_cast<int>(6.0 * dpr); // Толщина зоны захвата = 6 логических пикселей

        bool atLeft   = (x - winRect.left   < border);
        bool atRight  = (winRect.right  - x < border);
        bool atTop    = (y - winRect.top    < border);
        bool atBottom = (winRect.bottom - y < border);

        // Углы (для диагонального ресайза)
        if (atTop    && atLeft)  { *result = HTTOPLEFT;     return true; }
        if (atTop    && atRight) { *result = HTTOPRIGHT;    return true; }
        if (atBottom && atLeft)  { *result = HTBOTTOMLEFT;  return true; }
        if (atBottom && atRight) { *result = HTBOTTOMRIGHT; return true; }

        // Стороны
        if (atLeft)   { *result = HTLEFT;   return true; }
        if (atRight)  { *result = HTRIGHT;  return true; }
        if (atTop)    { *result = HTTOP;    return true; }
        if (atBottom) { *result = HTBOTTOM; return true; }

        // Не край окна — пусть Qt и QML обрабатывают (клики по кнопкам, ввод текста и т.д.)
        return false;
    }
    }
#else
    Q_UNUSED(eventType)
    Q_UNUSED(message)
    Q_UNUSED(result)
#endif
    return false;
}
