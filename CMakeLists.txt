cmake_minimum_required(VERSION 3.16)
project(Messami VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Network Widgets Sql)

set(SOURCES
    main.cpp
    messengercore.cpp messengercore.h
    messagemodel.cpp messagemodel.h
    networkmanager.cpp networkmanager.h
    framelesswindow.cpp framelesswindow.h
    databasemanager.cpp databasemanager.h
)

if(WIN32)
    list(APPEND SOURCES app_icon.rc)
endif()

qt_add_executable(appMessami ${SOURCES})

qt_add_qml_module(appMessami
    URI Messami
    VERSION 1.0
    QML_FILES Main.qml
    RESOURCES app_icon.ico
    SOURCES databasemanager.h databasemanager.cpp
)

target_link_libraries(appMessami
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::Network
        Qt6::Widgets
        Qt6::Sql
)

if(WIN32)
    target_link_libraries(appMessami PRIVATE dwmapi)
endif()

set_target_properties(appMessami PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
