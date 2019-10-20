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
    Q_INVOKABLE void setFiltersAndAddUsers(int gender = -1, int sortBy = 0, const QString& cityName = "");
    Q_INVOKABLE void closeApp();

private:
    std::unique_ptr<VK::Client> api_;
    VkUserModel&                model_;
};

} // App

#endif // CONTROLLER_H
