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
public:
    explicit Controller(VkUserModel& model, QObject *parent = nullptr);
    Q_INVOKABLE bool auth(const QString& login, const QString& password);
    Q_INVOKABLE bool getLikes(const QString& url);
    Q_INVOKABLE void setFiltersAndAddUsers(int gender = -1, int sortBy = 0, const QString& cityNames = "");
    Q_INVOKABLE void closeApp();
    Q_INVOKABLE bool tryAutologin();
    Q_INVOKABLE QString getUsername();

private:
    void saveApiToken(const QString& token);
    QString loadApiToken();

private:
    std::unique_ptr<VK::Client> api_;
    VkUserModel&                model_;
};

} // App

#endif // CONTROLLER_H
