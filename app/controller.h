#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>

#include <memory>

#include "api.h"
#include "vkUserModel.h"

namespace App
{

class Controller : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString code MEMBER code_ NOTIFY codeChanged)
public:
    explicit Controller(VkUserModel& model, QObject *parent = nullptr);
    Q_INVOKABLE bool auth(const QString& login, const QString& password);
    Q_INVOKABLE bool getLikes(const QString& url);
    Q_INVOKABLE void setFiltersAndAddUsers(int gender = -1, int sortBy = 0, const QString& cityNames = "");
    Q_INVOKABLE void closeApp();
    Q_INVOKABLE bool tryAutologin();
    Q_INVOKABLE QString getUsername();
    void        setQmlHandleObject(QObject* obj);

signals:
    void codeChanged();

private:
    void saveApiToken(const QString& token);
    QString loadApiToken();

    QString enterCaptcha(const QString& id);
    QString enterSMSCode();

private:
    std::unique_ptr<VK::Client> api_;
    VkUserModel&                model_;
    QString                     code_;
    QObject*                    qmlHandleObject_;
};

} // App

#endif // CONTROLLER_H
