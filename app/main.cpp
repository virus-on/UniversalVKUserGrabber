#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <qqmlengine.h>
#include <qqmlcontext.h>
#include <qqml.h>
#include <QtQuick/qquickitem.h>
#include <QtQuick/qquickview.h>

#include "controller.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    App::VkUserModel model;
    App::Controller  ctrl(model);

//    model.setUsers({
//                       App::User({"Kkk Kkk", 1, 2, "kkk", "qqq"}),
//                       App::User({"AAaaaaa BBBbbbb", 1, 2, "Rfgdf", "qwefdsfsfg"}),
//                       App::User({"Asdasfsdf dfgdfsgsd", 1, 2, "sadfsv", "sdfsdfs"}),
//                       App::User({"asddasdasd asdsad", 1, 2, "asdas", "asdas"}),
//                   });
//    model.addUsersToModel();

    QQuickStyle::setStyle("Material"); // Enable Material Design
    QQmlApplicationEngine engine;

    QQmlContext *ctxt = engine.rootContext();
    ctxt->setContextProperty("userListModel", &model);
    ctxt->setContextProperty("cppController", &ctrl);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;


    return app.exec();
}
